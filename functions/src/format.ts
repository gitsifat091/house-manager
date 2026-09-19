/** Bengali month names, matching the labels the app already uses. */
const MONTHS = [
  "জানুয়ারি",
  "ফেব্রুয়ারি",
  "মার্চ",
  "এপ্রিল",
  "মে",
  "জুন",
  "জুলাই",
  "আগস্ট",
  "সেপ্টেম্বর",
  "অক্টোবর",
  "নভেম্বর",
  "ডিসেম্বর",
];

/**
 * Month name for a 1-based month number, or an empty string when the value is
 * missing or out of range. Notification text is assembled from whatever the
 * document happens to hold, so this never throws.
 */
export function monthName(month: unknown): string {
  if (typeof month !== "number" || !Number.isInteger(month)) return "";
  if (month < 1 || month > 12) return "";
  return MONTHS[month - 1];
}
