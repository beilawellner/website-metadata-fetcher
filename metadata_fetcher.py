import requests
from bs4 import BeautifulSoup
import json
import re
import logging
from typing import Dict, Optional
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class WebsiteMetadata:
    def __init__(self, domain: str):
        self.domain = domain
        self.final_url: Optional[str] = None
        self.title: Optional[str] = None
        self.google_analytics_id: Optional[str] = None

    def fetch_metadata(self) -> None:
        try:
            logging.info(f"Fetching data for domain: {self.domain}")

            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            }
            response = requests.get(f"http://{self.domain}", headers=headers, allow_redirects=True)

            # Extract the full URL
            self.final_url = response.url
            
            # Extract title
            soup = BeautifulSoup(response.content, 'html.parser')
            self.title = soup.title.string if soup.title else "No Title Found"

            self.google_analytics_id = self.extract_google_analytics_id(soup)
        except requests.RequestException as e:
            logging.error(f"Error fetching data for domain: {self.domain} - {e}")
            raise

    def extract_google_analytics_id(self, soup: BeautifulSoup) -> Optional[str]:
        ga_pattern = re.compile(r"(UA|GT)-\d{8,14}")
        for script in soup.find_all('script'):
            if script.string:
                ga_id = ga_pattern.search(script.string)
                if ga_id:
                    return ga_id.group(0)
        return None  # Return None if not found

    def to_dict(self) -> Dict[str, Optional[str]]:
        return {
            "domain": self.domain,
            "redirect": self.final_url,
            "title": self.title,
            "google_analytics_id": self.google_analytics_id
        }

class WebsiteMetadataFetcher:
    def __init__(self, domains: list[str]):
        self.domains = domains

    def get_metadata(self) -> None:
        with ThreadPoolExecutor(max_workers=10) as executor:
            results = list(executor.map(self.fetch_metadata_for_domain, self.domains))
            for result in results:
                if result:
                    self.print_metadata_as_json(result)

    def fetch_metadata_for_domain(self, domain: str) -> WebsiteMetadata:
        metadata = WebsiteMetadata(domain.strip())
        try:
            metadata.fetch_metadata()
            return metadata
        except Exception as e:
            logging.error(f"Failed to get metadata for {domain}: {e}")
            return None

    def print_metadata_as_json(self, metadata: WebsiteMetadata) -> None:
        metadata_dict = metadata.to_dict()
        print(json.dumps(metadata_dict, indent=4))
