# Website Metadata Fetcher

This project is a tool that fetches metadata (such as titles, descriptions, etc.) from websites by providing one or more domain names. It supports input from the command line or from a file (`domains.txt`), and it uses multithreading to speed up metadata fetching.

## Features

- Fetch metadata from multiple websites concurrently.
- Input domains either interactively via the command line or from a file.
- Can be run in a Docker container.
- Logs metadata fetching process for easy debugging.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Docker](#docker)

## Installation

### Requirements

- Python 3.12+
- Docker (optional for containerized usage)

Set up the Python environment
It's recommended to use a virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
```

Install the dependencies:
```bash
pip install -r requirements.txt
```

## Usage
From the Command Line
You can provide domains either by entering them manually or from a file:

Interactive input:
```bash
python main.py
```
You will be prompted to input domain names separated by commas (e.g., google.com, facebook.com).

File input:
Use the --file argument to specify a file containing a list of domain names (one per line):

```bash
python app/main.py --file domains.txt
```

Example domains.txt file:
```text
reddit.com
tumblr.com
snapchat.com
```

### Example Output

When you run the project, you will see logs of the metadata fetching process, including the domain name, redirect URL, title, and Google Analytics ID (if available). Below is an example output when fetching metadata for multiple domains:

```json
{
    "domain": "reddit.com",
    "redirect": "https://www.reddit.com/?rdt=47631",
    "title": "Reddit - Dive into anything",
    "google_analytics_id": null
}
{
    "domain": "tumblr.com",
    "redirect": "https://www.tumblr.com/",
    "title": "Trending topics on Tumblr",
    "google_analytics_id": null
}
{
    "domain": "snapchat.com",
    "redirect": "https://www.snapchat.com:443/",
    "title": "Less social media. More Snapchat.",
    "google_analytics_id": "UA-41740027"
}
```

## Docker
You can also run the project using Docker for a more isolated environment.

Build the Docker image
```bash
docker build -t metadata-fetcher .
```
Run the Docker container
With file input:
```bash
docker run --rm metadata-fetcher
```
By default, the container will look for domains.txt inside the container. If you want to pass your own file from the host system:

```bash
docker run --rm -v $(pwd)/domains.txt:/app/domains.txt metadata-fetcher
```
Interactive input:
You can also enter domains interactively by running the container without the --file argument:

```bash
docker run --rm -it metadata-fetcher
```
vbnet
Copy code
