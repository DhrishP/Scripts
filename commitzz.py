import subprocess
from openai import OpenAI
import os
import argparse
from dotenv import load_dotenv 

load_dotenv()

# Configure your OpenAI API key
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def get_staged_files():
    """Get a list of already staged files."""
    result = subprocess.run(["git", "diff", "--cached", "--name-only"], capture_output=True, text=True)
    return [file for file in result.stdout.splitlines() if os.path.isfile(file)]

def get_unstaged_modified_files():
    """Get a list of modified but unstaged files (not just directories)."""
    result = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
    modified_files = []
    for line in result.stdout.splitlines():
        if (line.startswith("M ") or line.startswith("?? ")) and not line.startswith("M  "):
            file_path = line.split()[1]
            if os.path.isfile(file_path):
                modified_files.append(file_path)
    return modified_files

def stage_files(file_paths):
    """Stage multiple files for commit."""
    subprocess.run(["git", "add"] + file_paths)

def generate_commit_message(file_paths):
    """Generate a commit message using OpenAI for multiple files."""
    files_str = ", ".join(file_paths)
    prompt = f"Write a concise Git commit message for changes made in the following files: {files_str}"
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful assistant that writes concise, meaningful git commit messages."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=50
        )
        message = response.choices[0].message.content.strip()
        return message
    except Exception as e:
        print(f"Error generating commit message: {e}")
        return f"Updated files: {files_str}"

def commit_files(commit_message):
    """Commit staged files with a specific commit message."""
    subprocess.run(["git", "commit", "-m", commit_message])

def push_changes():
    """Push changes to the GitHub repository."""
    subprocess.run(["git", "push"])

def process_files_in_batches(files, batch_size=2):
    """Process files in batches of specified size, but push only at the end."""
    if not files:
        return
        
    total_batches = (len(files) + batch_size - 1) // batch_size
    
    for i in range(0, len(files), batch_size):
        batch = files[i:i + batch_size]
        current_batch = (i // batch_size) + 1
        print(f"\nProcessing batch {current_batch}/{total_batches}: {', '.join(batch)}")
        
        # Unstage all files first
        subprocess.run(["git", "reset"])
        
        # Stage only this batch
        stage_files(batch)
        
        commit_message = generate_commit_message(batch)
        print(f"Commit message: {commit_message}")
        
        commit_files(commit_message)
        print(f"Batch {current_batch} committed.")

def main():
    # Add argument parser
    parser = argparse.ArgumentParser(description='Auto-commit and push Git changes in batches.')
    parser.add_argument('--batch-size', type=int, default=2,
                       help='Number of files to process in each batch (default: 2)')
    args = parser.parse_args()
    
    # Combine all files that need processing
    all_files = get_staged_files() + get_unstaged_modified_files()
    
    if not all_files:
        print("No files to commit.")
        return
        
    print(f"\nFound {len(all_files)} files to process")
    process_files_in_batches(all_files, batch_size=args.batch_size)
    
    # Push all commits at once
    print("\nPushing all commits to GitHub...")
    push_changes()
    print("All changes have been committed and pushed.")

if __name__ == "__main__":
    main()