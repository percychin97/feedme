import 'dart:math';

import 'package:feedme/enum.dart';

///
/// FOOD ORDER OBJECT THAT WILL BE PROCESSED
///

class FoodOrder{
  OrderStatus orderStatus = OrderStatus.pending;
  bool isVipOrder = false;
  String createdAt = DateTime.now().toString();
  int orderNumber = 0;
}