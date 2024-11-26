const cloudinary = require("cloudinary").v2;
const path = require("path");
const dotenv = require('dotenv')
dotenv.config()
// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Function to upload a single file
async function uploadFile(filePath) {
  try {
    const result = await cloudinary.uploader.upload(filePath, {
      resource_type: "auto", // automatically detect file type
    });
    return {
      success: true,
      url: result.secure_url,
      public_id: result.public_id,
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
    };
  }
}

// Function to handle multiple files
async function uploadMultipleFiles(filePaths) {
  const results = [];

  for (const filePath of filePaths) {
    const absolutePath = path.resolve(filePath);
    console.log(`Uploading: ${absolutePath}`);
    const result = await uploadFile(absolutePath);
    results.push({
      path: filePath,
      ...result,
    });
  }

  return results;
}

// Modified main function
async function main() {
  // Get all file paths from command line arguments
  const filePaths = process.argv.slice(2);

  if (filePaths.length === 0) {
    console.error("Please provide at least one file path");
    process.exit(1);
  }

  const results = await uploadMultipleFiles(filePaths);

  console.log("\nUpload Results:");
  results.forEach((result) => {
    console.log("\n-------------------");
    console.log("File:", result.path);
    if (result.success) {
      console.log("Status: Success");
      console.log("URL:", result.url);
    } else {
      console.log("Status: Failed");
      console.log("Error:", result.error);
    }
  });
}

main().catch(console.error);
