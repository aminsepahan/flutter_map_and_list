import 'package:get_it/get_it.dart';

import '../../models/network/api_response.dart';
import '../../utils/network/dio_caller.dart';

class CampListProvider {
  DioCaller dioCaller = GetIt.I<DioCaller>();

  Future<ApiResponse> fetchCampList() {
    return dioCaller.get('/campsites');
  }
}
