import 'package:expense_wise/core/service/db_service.dart';
import 'package:expense_wise/data/model/expense_local_service_response.dart';
import 'package:expense_wise/domain/service/expense_data_local_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseDataLocalServiceImpl extends ExpenseDataLocalService{

  final DBService dbService;
  ExpenseDataLocalServiceImpl({required this.dbService});


  @override
  Future<ExpenseLocalServiceResponse> addExpense({required Map<String, dynamic> expenseData}) async {
    try{
      int id = await dbService.addExpense(expenseData);
      if(id != -1){
        return ExpenseLocalServiceResponse(success: true,data: {'id':id});
      }else{
        return ExpenseLocalServiceResponse(success: false, errorMsg: "Unable to add expense");
      }
    }catch(e){
      return ExpenseLocalServiceResponse(success: false, errorMsg: e.toString());
    }
  }

  @override
  Future<ExpenseLocalServiceResponse> deleteExpense({required int id}) async{
    try{
      bool success = await dbService.deleteExpense(id: id);
      if(success){
        return ExpenseLocalServiceResponse(success: true,);
      }else{
        return ExpenseLocalServiceResponse(success: false, errorMsg: "Unable to delete expense");
      }
    }catch(e){
      return ExpenseLocalServiceResponse(success: false, errorMsg: e.toString());
    }
  }

  @override
  Future<ExpenseLocalServiceResponse> getAllExpenses() async{
    try{
      List<Map<String,dynamic>> data = await dbService.getAllExpenses();
      return ExpenseLocalServiceResponse(success: true,data: data);
    } catch(e){
      return ExpenseLocalServiceResponse(success: false, errorMsg: e.toString());
    }
  }

  @override
  Future<ExpenseLocalServiceResponse> updateExpense({required Map<String, dynamic> updatedExpenseData, required int id}) async{
    try{
      bool success = await dbService.updateExpense(id: id, updatedExpense: updatedExpenseData);
      if(success){
        return ExpenseLocalServiceResponse(success: true,);
      }else{
        return ExpenseLocalServiceResponse(success: false, errorMsg: "Unable to update expense");
      }
    }catch(e){
      return ExpenseLocalServiceResponse(success: false, errorMsg: e.toString());
    }
  }

}

final expenseDataLocalServiceImplProvider = Provider((ref) => ExpenseDataLocalServiceImpl(dbService: ref.read(dbServiceProvider)));