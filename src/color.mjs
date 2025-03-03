// Function to convert a string to a hex color code
function stringToColor(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
      hash = str.charCodeAt(i) + ((hash << 5) - hash);
  }
  let color = "#";
  for (let i = 0; i < 3; i++) {
      let value = (hash >> (i * 8)) & 0xff;
      color += ("00" + value.toString(16)).slice(-2);
  }
  return color;
}

// Function to convert a hex color to RGBA
function hexToRgba(hex, alpha = 1) {
  // Remove the hash if it exists
  hex = hex.replace(/^#/, '');

  // Parse hex color
  let r = parseInt(hex.substring(0, 2), 16);
  let g = parseInt(hex.substring(2, 4), 16);
  let b = parseInt(hex.substring(4, 6), 16);

  // Return the RGBA format
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

// Combined function to generate RGBA from a string
export default function stringToRgba(str, alpha = 1) {
  const hexColor = stringToColor(str);
  return hexToRgba(hexColor, alpha);
}

// Example usage:
// console.log(stringToRgba("Hello World", 0.5)); // e.g., "rgba(94, 42, 140, 0.5)"