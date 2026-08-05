import 'dart:async';
import '../domain/models/recording_models.dart';
import '../../../core/network/http_client.dart';

abstract class IAiService {
  Future<AiMeetingSummary> generateSummary(String transcript);
  Future<String> askQuestion(String question, String contextTranscript);
}

class AiServiceImpl implements IAiService {
  final HttpApiClient httpClient;
  bool useMock;

  AiServiceImpl({
    required this.httpClient,
    this.useMock = true,
  });

  @override
  Future<AiMeetingSummary> generateSummary(String transcript) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return const AiMeetingSummary(
        rawSummary:
            "Discussion focused on ESP32-S3 hardware streaming PCM audio over WebSocket to Node.js backend. ElevenLabs Scribe STT performs transcription while Google Gemini synthesizes action items and meeting insights.",
        bulletPoints: [
          "ESP32-S3 streams audio chunked in 10-second WAV segments.",
          "Flutter App renders real-time audio waveform and live transcript.",
          "Gemini API handles automated action item generation and Q&A."
        ],
        actionItems: [
          "Verify sub-2-second telemetry ACK on AWS IoT Core.",
          "Complete Riverpod state provider integration for floating bottom navbar.",
          "Test Gemini /ask endpoint with long transcript history."
        ],
      );
    }

    try {
      final response = await httpClient.post('/generate-summary', {
        'transcript': transcript,
      });
      return AiMeetingSummary.fromJson(response);
    } catch (_) {
      return const AiMeetingSummary(
        rawSummary: "Could not generate summary from backend service.",
        bulletPoints: ["Check network connection to Express AI server."],
        actionItems: [],
      );
    }
  }

  @override
  Future<String> askQuestion(String question, String contextTranscript) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return "Based on your meeting transcript: The team decided to use Riverpod for Flutter state management, clean light blue styling with Material 3, and sub-2s telemetry target over AWS IoT Core.";
    }

    try {
      final response = await httpClient.post('/ask', {
        'question': question,
        'context': contextTranscript,
      });
      return response['answer'] ?? "No answer received from AI.";
    } catch (_) {
      return "Unable to process question. Please check server connection.";
    }
  }
}
