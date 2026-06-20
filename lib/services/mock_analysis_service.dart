// File: lib/services/mock_analysis_service.dart

Future<Map<String, dynamic>> analyzeText(String text) async {
  await Future.delayed(const Duration(seconds: 2)); // Simulate API call
  
  final lower = text.toLowerCase();
  if (lower.contains('hate') || lower.contains('stupid') || lower.contains('idiot')) {
    return {
      'label': 'harmful',
      'fusedScore': 0.92,
      'explanation': 'This text contains aggressive language and personal attacks.',
      'suggestions': [
        'I disagree with your perspective.',
        'I see things differently.',
        'Let\'s discuss this respectfully.'
      ]
    };
  } else if (lower.contains('disagree') || lower.contains('wrong')) {
    return {
      'label': 'borderline',
      'fusedScore': 0.65,
      'explanation': 'This text expresses disagreement but could be phrased more constructively.',
      'suggestions': [
        'I understand your point, but I have a different view.',
        'Could you explain why you think that?'
      ]
    };
  } else {
    return {
      'label': 'safe',
      'fusedScore': 0.05,
      'explanation': 'This text appears to be safe and respectful.',
      'suggestions': []
    };
  }
}

Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
  await Future.delayed(const Duration(seconds: 2));
  return {
    'label': 'safe',
    'fusedScore': 0.1,
    'explanation': 'The image does not appear to contain harmful content.',
    'suggestions': []
  };
}

Future<Map<String, dynamic>> analyzeTextAndImage(String text, String imagePath) async {
  return analyzeText(text); // Simplified for mock
}
