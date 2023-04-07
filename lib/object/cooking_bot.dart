import 'dart:math';

import 'package:feedme/enum.dart';

///
/// COOKING BOT OBJECT USED TO PROCESS FOOD ORDER
///

class CookingBot{
  BotStatus botStatus = BotStatus.idle;
  int botId = Random().nextInt(999999);
}