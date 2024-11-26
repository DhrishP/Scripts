# Development Automation Scripts

A collection of utility scripts to automate common development tasks.

## Scripts Overview

### 1. Image Uploader (imgup)

Automatically uploads images to Cloudinary and returns public URLs.

**Files:**

- `imgup.js` - Main Node.js script for image uploading
- `imgup.bat` - Windows batch file for easy command-line access

**Setup:**

1. Add the directory of the script to your PATH environment variable.
2. Create a `.env` file with your Cloudinary credentials:
   - `CLOUDINARY_CLOUD_NAME`
   - `CLOUDINARY_API_KEY`
   - `CLOUDINARY_API_SECRET`
3. run imgup <image_path> to upload the image

### 2. Commit Message Generator (commitzz)

Generates meaningful commit messages using AI for when you are committing a lot of files.

**Files:**

- `commitzz.py` - Python script for commit message generation
- `commitzz.bat` - Windows batch file for easy command-line access

**Setup:**

1. Add the directory of the script to your PATH environment variable.
2. Create a `.env` file with your OpenAI API key:
   - `OPENAI_API_KEY`
3. run commitzz --batch-size=<number> to generate a commit message for a batch of files
