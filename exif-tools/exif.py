from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS

input_image_path = '/Users/pakk/Downloads/testing/1.png'
output_image_path = '/Users/pakk/Downloads/testing/out.png'

def copy_parameter_to_user_comment(input_image_path, output_image_path):
    # Open the image using Pillow
    image = Image.open(input_image_path)

    # Get the existing Exif data
    exif_data = image.info.get("exif")

    if exif_data:
        # Decode the Exif data into a dictionary
        exif_dict = {
            TAGS[key]: value
            for key, value in exif_data.items()
            if key in TAGS
        }

        # Check if the "Parameters" field exists in Exif data
        if "Parameters" in exif_dict:
            # Copy the "Parameters" value to "UserComment"
            exif_dict["UserComment"] = exif_dict["Parameters"]

            # Remove the "Parameters" field
            del exif_dict["Parameters"]

            # Encode the modified Exif data back to binary format
            new_exif_data = {
                TAGS[key]: value
                for key, value in exif_dict.items()
            }
            exif_bytes = image._getexif()
            exif_bytes.update(new_exif_data)

            # Update the image with the modified Exif data
            image.save(output_image_path, exif=exif_bytes)
        else:
            print("No 'Parameters' field found in Exif data.")
    else:
        print("No Exif data found in the image.")

if __name__ == "__main__":
    input_image_path = "input.png"
    output_image_path = "output.png"
    
    copy_parameter_to_user_comment(input_image_path, output_image_path)
    print(f"Parameters copied to UserComment and removed in '{output_image_path}'")
