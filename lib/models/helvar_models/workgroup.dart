import '../../utils/core/path_utils.dart';
import 'helvar_router.dart';
import 'helvar_group.dart';

class Workgroup {
  final String id;
  String description;
  final String gatewayRouterIpAddress;

  List<HelvarRouter> routers;
  List<HelvarGroup> groups;

  String get pathSegment =>
      sanitizePathSegment(description.isNotEmpty ? description : id);

  static Workgroup empty(String id) => Workgroup(id: id);

  Workgroup({
    required this.id,
    this.description = '',
    this.gatewayRouterIpAddress = '',
    List<HelvarRouter>? routers,
    List<HelvarGroup>? groups,
  }) : routers = routers ?? [],
       groups = groups ?? [];

  void addRouter(HelvarRouter router) {
    routers.add(router);
  }

  void removeRouter(HelvarRouter router) {
    routers.remove(router);
  }

  void addGroup(HelvarGroup group) {
    groups.add(group);
  }

  void removeGroup(HelvarGroup group) {
    groups.remove(group);
  }
}
