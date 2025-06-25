import 'package:road_surfer_task/resources/network/camp_list_provider.dart';
import '../../models/network/api_response.dart';

class CampListRepository {
  final CampListProvider campListProvider = CampListProvider();

  Future<ApiResponse> fetchCampList() {
    return campListProvider.fetchCampList();
  }

}
