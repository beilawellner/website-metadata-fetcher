import logging
import sys
from metadata_fetcher import WebsiteMetadataFetcher

def read_domains_from_file(file_path):
    try:
        with open(file_path, 'r') as file:
            domains = file.read().strip().splitlines()
            return [domain.strip() for domain in domains if domain]
    except Exception as e:
        logging.error(f"Error reading domains from file: {e}")
        return []

def get_domains_from_input():
    domain_input = input("Enter one or more domains separated by commas: ").strip()
    return [domain.strip() for domain in domain_input.split(',') if domain]

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


    if len(sys.argv) > 1 and sys.argv[1] == "--file":
        domain_file = sys.argv[2]
        domain_list = read_domains_from_file(domain_file)
    else:
        domain_list = get_domains_from_input()

    if domain_list:
        fetcher = WebsiteMetadataFetcher(domain_list)
        fetcher.get_metadata()
    else:
        logging.error("No valid domains found.")
    print("test")

