import 'package:expense_wise/core/service/navigation_service.dart';
import 'package:expense_wise/domain/service/ui_helper_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UIHelperServiceImpl extends UIHelperService{
  final NavigationService navigationService;

  UIHelperServiceImpl({required this.navigationService});

  @override
  void goBackToPreviousScreen() {
    navigationService.pop();
  }

  @override
  void showSnackBar({required String msg}) {
    navigationService.showSnackBar(msg: msg);
  }

}

final uiServiceHelperProvider = Provider((ref)=> UIHelperServiceImpl(navigationService: NavigationService.instance));