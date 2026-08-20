import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/models/meeting.dart';
import '/models/participant.dart';

class MeetingService {
  final ApiClient _api = ApiClient();

  String _extractMensaje(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data["mensaje"] != null) {
      return data["mensaje"].toString();
    }
    return fallback;
  }

  /// GET /eventos
  Future<List<Meeting>> getMeetings() async {
    try {
      final response = await _api.dio.get("/eventos");
      final data = response.data;

      final List<dynamic> eventos;
      if (data is List) {
        eventos = data;
      } else if (data is Map && data["eventos"] is List) {
        eventos = data["eventos"];
      } else {
        eventos = [];
      }

      return eventos.map((json) => Meeting.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al obtener los eventos"));
    }
  }

  /// POST /eventos -> { mensaje, evento }
  Future<Meeting> createMeeting({
    required String title,
    required DateTime date,
    required String time,
    required String location,
    int toleranceMinutes = 20,
    TipoReunion tipoReunion = TipoReunion.soloMiembros,
  }) async {
    try {
      final meeting = Meeting(
        id: 0,
        title: title,
        date: date,
        time: time,
        location: location,
        toleranceMinutes: toleranceMinutes,
        tipoReunion: tipoReunion,
      );

      final response = await _api.dio.post(
        "/eventos",
        data: meeting.toJson(),
      );

      final data = response.data;
      final eventoJson = (data is Map && data["evento"] != null)
          ? data["evento"]
          : data;

      return Meeting.fromJson(eventoJson);
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al crear la reunión"));
    }
  }

  /// PUT /eventos/:id -> { mensaje, evento }
  Future<Meeting> updateMeeting({
    required int id,
    required String title,
    required DateTime date,
    required String time,
    required String location,
    int toleranceMinutes = 20,
    TipoReunion tipoReunion = TipoReunion.soloMiembros,
  }) async {
    try {
      final meeting = Meeting(
        id: id,
        title: title,
        date: date,
        time: time,
        location: location,
        toleranceMinutes: toleranceMinutes,
        tipoReunion: tipoReunion,
      );

      final response = await _api.dio.put(
        "/eventos/$id",
        data: meeting.toJson(),
      );

      final data = response.data;
      final eventoJson = (data is Map && data["evento"] != null)
          ? data["evento"]
          : data;

      return Meeting.fromJson(eventoJson);
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al editar la reunión"));
    }
  }

  /// DELETE /eventos/:id
  Future<void> deleteMeeting(int id) async {
    try {
      await _api.dio.delete("/eventos/$id");
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al eliminar la reunión"));
    }
  }

  Future<Participant> asociarParticipante({
    required int eventoId,
    required int usuarioId,
  }) async {
    try {
      final response = await _api.dio.post(
        "/eventos/$eventoId/participantes",
        data: {"usuarioId": usuarioId},
      );

      return Participant.fromJson(response.data["participante"]);
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al asociar participante"));
    }
  }

  /// GET /eventos/:id/participantes -> Participantes de un evento,
  Future<List<Participant>> listarParticipantes(int eventoId) async {
    try {
      final response = await _api.dio.get("/eventos/$eventoId/participantes");
      final data = response.data;

      final List<dynamic> raw =
          (data is Map && data["participantes"] is List)
              ? data["participantes"]
              : (data is List ? data : []);

      return raw.map((json) => Participant.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al obtener participantes"));
    }
  }
}