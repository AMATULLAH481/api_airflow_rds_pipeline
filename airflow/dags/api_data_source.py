import random
import requests

SUBJECTS = [
    "fear", "love", "adventure", "history", "science", "drama",
    "mystery", "fantasy", "philosophy", "biography"
]

def fetch_books_data(year=2024, limit=20, sample_size=5):
    subject = random.choice(SUBJECTS)
    print(f"Fetching books for subject: {subject}\n")
    
    url = f"http://openlibrary.org/subjects/{subject}.json?published_in={year}&limit={limit}"
    response = requests.get(url)
    the_data = response.json()

    updated_data = []
    for work in the_data.get("works", []):
        title = work.get("title")
        subjects = work.get("subject", [])[:5]
        authors = [author.get("name") for author in work.get("authors", [])]
        updated_data.append((title, subjects, authors))
        
    selected_books = random.sample(updated_data, min(sample_size, len(updated_data)))
    
    return selected_books

test = fetch_books_data ()
print(test)