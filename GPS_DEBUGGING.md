# GPS Location Debugging Guide

If your images are showing incorrect locations in Apple Photos (e.g., South Pacific Ocean), follow these steps:

## Step 1: Check Console Output

When you run the app, check the Xcode console for GPS coordinate information:

Look for lines like:
```
GPS Latitude: 37.7749 N (from input: 37.7749, ref: N)
GPS Longitude: 122.4194 W (from input: -122.4194, ref: W)
```

**What to check:**
- Are the coordinates being parsed correctly?
- Are the references (N/S/E/W) correct?
- Do you see any warnings about coordinate swaps or invalid values?

## Step 2: Verify JSON Data

Check your JSON file to ensure GPS data is correct:

```json
{
  "GPSLatitude": "37.7749",
  "GPSLatitudeRef": "N",
  "GPSLongitude": "-122.4194",
  "GPSLongitudeRef": "W"
}
```

**Common issues:**
1. **Coordinates swapped**: Latitude and longitude might be reversed
2. **Missing references**: GPSLatitudeRef or GPSLongitudeRef might be missing
3. **Wrong format**: Coordinates might be in DMS format when decimal is expected (or vice versa)

## Step 3: Check Written Metadata

Use the diagnostic script to check what's actually written to your image:

```bash
./check_gps_metadata.sh /path/to/your/image.jpg
```

Or use ExifTool directly:
```bash
exiftool -GPS:all -n /path/to/your/image.jpg
```

**What to look for:**
- GPSLatitude: Should be a positive number (0-90)
- GPSLatitudeRef: Should be "N" or "S"
- GPSLongitude: Should be a positive number (0-180)
- GPSLongitudeRef: Should be "E" or "W"

## Step 4: Test with Known Coordinates

Try updating an image with known coordinates to verify the app is working:

Example (San Francisco):
- Latitude: 37.7749 (or "37.7749" with ref "N")
- Longitude: -122.4194 (or "122.4194" with ref "W")

## Common Issues and Solutions

### Issue: Coordinates show in South Pacific Ocean

**Possible causes:**
1. **Coordinates are 0,0** - Check if your JSON has valid GPS data
2. **Coordinates are swapped** - Latitude and longitude might be reversed in your JSON
3. **Wrong references** - N/S/E/W might be incorrect
4. **Missing references** - References might be missing or empty

### Issue: "WARNING: Possible coordinate swap detected!"

This means the latitude value is > 90 degrees, which suggests coordinates might be swapped in your source data.

**Solution:** Check your JSON file and ensure:
- GPSLatitude is between -90 and 90
- GPSLongitude is between -180 and 180
- They are not reversed

### Issue: Coordinates parse correctly but location is still wrong

**Possible causes:**
1. **Apple Photos cache** - Try restarting Photos app or importing to a new library
2. **Image format** - Some RAW formats might not preserve GPS data correctly
3. **Multiple GPS tags** - There might be conflicting GPS data in the image

## Coordinate Format Support

The app supports multiple coordinate formats:

### Decimal Degrees (recommended):
```json
{
  "GPSLatitude": "37.7749",
  "GPSLatitudeRef": "N",
  "GPSLongitude": "-122.4194",
  "GPSLongitudeRef": "W"
}
```

### Decimal with sign (no reference needed):
```json
{
  "GPSLatitude": "-37.7749",
  "GPSLatitudeRef": "",
  "GPSLongitude": "122.4194",
  "GPSLongitudeRef": ""
}
```

### Degrees Minutes Seconds (DMS):
```json
{
  "GPSLatitude": "37deg 46' 29.64\" N",
  "GPSLatitudeRef": "",
  "GPSLongitude": "122deg 25' 9.84\" W",
  "GPSLongitudeRef": ""
}
```

## Still Having Issues?

1. **Share the console output** - The GPS coordinate logging will show what's being parsed
2. **Share a sample JSON entry** - This helps identify format issues
3. **Run the diagnostic script** - This shows what's actually written to the image
4. **Check Apple Photos directly** - Sometimes Photos needs to be restarted to refresh location data

## Technical Details

- GPS coordinates are stored as **positive decimal degrees** with **reference indicators** (N/S/E/W)
- This is the standard EXIF GPS format required by iOS/macOS
- Latitude must be between -90 and 90
- Longitude must be between -180 and 180
- Coordinates outside these ranges will be rejected

