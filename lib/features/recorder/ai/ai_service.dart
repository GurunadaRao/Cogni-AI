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
    this.useMock = false,
  });

  @override
  Future<AiMeetingSummary> generateSummary(String transcript) async {
    try {
      final response = await httpClient.post('/generate-summary', {
        'transcript': transcript,
      });
      return AiMeetingSummary.fromJson(response);
    } catch (_) {
      return const AiMeetingSummary(
        rawSummary: "Could not generate summary from backend service.",
        bulletPoints: ["Check network connection to backend server."],
        actionItems: [],
      );
    }
  }

  @override
  Future<String> askQuestion(String question, String contextTranscript) async {
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
