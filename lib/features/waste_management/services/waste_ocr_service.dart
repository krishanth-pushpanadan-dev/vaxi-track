import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class WasteOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Extract text from a medicine/package image using OCR.
  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    return recognizedText.text;
  }

  /// Performs local/mock image analysis.
  ///
  /// This is intentionally a lightweight analysis layer for the
  /// frontend/mock-data stage of VaxiTrack.
  ///
  /// It does NOT automatically declare a medicine unsafe.
  /// The user must verify the detected issue.
  Future<WasteImageAnalysisResult> analyzeImage({
    required String imagePath,
    required String extractedText,
  }) async {
    // Simulate a short analysis process.
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedText = extractedText.toLowerCase();

    // ------------------------------------------------------------
    // EXPIRY INFORMATION
    // ------------------------------------------------------------

    final hasExpiryInformation =
        normalizedText.contains('exp') ||
        normalizedText.contains('expiry') ||
        normalizedText.contains('expiration') ||
        normalizedText.contains('expires');

    // ------------------------------------------------------------
    // POSSIBLE DAMAGE
    // ------------------------------------------------------------
    //
    // This is currently a mock/local indicator.
    //
    // Later, this method can be replaced with a real computer
    // vision model that analyzes the actual image pixels.
    //
    // The system will still return "possible damage" and require
    // user confirmation.
    // ------------------------------------------------------------

    final possibleDamageKeywords = [
      'damaged',
      'damage',
      'broken',
      'cracked',
      'crack',
      'leak',
      'leaking',
      'torn',
      'opened',
      'broken seal',
    ];

    final possibleDamage = possibleDamageKeywords.any(normalizedText.contains);

    String message;

    if (possibleDamage) {
      message =
          'Possible package damage detected. Please verify the image and medicine condition.';
    } else if (hasExpiryInformation) {
      message = 'Expiry information found. Please verify the expiry date.';
    } else {
      message =
          'Image analyzed. Please verify the medicine condition and extracted information.';
    }

    return WasteImageAnalysisResult(
      possibleDamage: possibleDamage,
      hasExpiryInformation: hasExpiryInformation,
      message: message,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}

/// Result returned by the image-analysis layer.
class WasteImageAnalysisResult {
  final bool possibleDamage;
  final bool hasExpiryInformation;
  final String message;

  const WasteImageAnalysisResult({
    required this.possibleDamage,
    required this.hasExpiryInformation,
    required this.message,
  });
}
