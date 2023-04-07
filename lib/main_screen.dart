import 'package:feedme/common_widget/buttons.dart';
import 'package:feedme/common_widget/screens.dart';
import 'package:feedme/enum.dart';
import 'package:feedme/object/cooking_bot.dart';
import 'package:feedme/object/food_order.dart';
import 'package:feedme/utils.dart';
import 'package:flutter/material.dart';

///
/// MAIN SCREEN DISPLAY IN APP
///

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {

  /// UI RELATED PARAMS
  late TabController _tabController;
  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.emoji_food_beverage), text: 'PENDING',),
    Tab(icon: Icon(Icons.fastfood), text: 'COMPLETE',),
    Tab(icon: Icon(Icons.cookie), text: 'BOTS'),
  ];

  /// FUNCTION RELATED PARAMS
  List<CookingBot> botList = [];
  List<FoodOrder> orderList = [];
  List<FoodOrder> vipOrderList = [];
  Map botProcessMap = {};
  int orderNumberIncrement = 0;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    /// RUN CORE ALGORITHM FUNCTIONAL LOOP FOR ASYNCHRONOUS PROCESSING BACKGROUND
    coreAlgorithmLoop();
  }

  @override
  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  void coreAlgorithmLoop()async{
    while(mounted){
      await Future.delayed(const Duration(seconds: 1));

      /// IF TOTAL ORDERS OR BOTS EMPTY, RERUN LOOP, NO POINT RUNNING FUNCTION BELOW
      List totalOrderList = [...vipOrderList, ...orderList];
      if(totalOrderList.isEmpty || botList.isEmpty) continue;

      /// CHECK ALL FOOD ORDERS IN LIST
      for(FoodOrder foodOrder in totalOrderList){
        /// CHECK IF ANY FOOD ORDER CURRENTLY IN PENDING STATUS
        if(foodOrder.orderStatus == OrderStatus.pending){
          for(CookingBot cookingBot in botList){
            /// CHECK IF ANY BOT CURRENTLY IN IDLE STATUS
            if(cookingBot.botStatus == BotStatus.idle){
              /// SET BOT AND FOOD TO PROCESSING AND RUN BOT PROCESS FOOD FUNCTION
              cookingBot.botStatus = BotStatus.processing;
              foodOrder.orderStatus = OrderStatus.processing;
              botProcessFood(cookingBot.botId, foodOrder.orderNumber);
              break;
            }
          }
        }
      }

      /// REFRESH SCREEN UI
      setState(() {});
    }
  }


  void botProcessFood(int botId, int orderId)async{
    /// USE BOT PROCESS MAP TO TRACK WHICH BOT PROCESS WHICH ORDER
    botProcessMap[botId] = orderId;
    /// ASYNCHRONOUSLY WAIT 10 SECOND FOR THE PROCESS TO COMPLETE
    await Future.delayed(const Duration(seconds: 10));

    List totalOrderList = [...vipOrderList, ...orderList];
    ///
    /// AFTER 10 SECOND, CHECK AGAIN SEE IF THE BOT AND ORDER STILL THERE, AND WHETHER FOOD STILL PROCESSING
    /// IF ALL CONDITION MEET, CHANGE FOOD TO COMPLETE STATUS AND BOT TO IDLE STATUS, REMOVE THE TRACK IN MAP
    for(FoodOrder foodOrder in totalOrderList){
      if(foodOrder.orderNumber == orderId && foodOrder.orderStatus == OrderStatus.processing){
        foodOrder.orderStatus = OrderStatus.completed;
        for(CookingBot cookingBot in botList){
          if(cookingBot.botId == botId){
            cookingBot.botStatus = BotStatus.idle;
            botProcessMap[botId] = null;
          }
        }
      }
    }
  }

  /// UI TO DISPLAY FOOD ORDER LIST, VIP ORDER ALWAYS COMES FIRST
  Widget wFoodOrderList({bool isCompleteOnly=false}){
    List totalOrderList = [...vipOrderList, ...orderList];

    Widget wFoodOrder(int index){
      FoodOrder foodOrder = totalOrderList[index];

      String status = '';
      switch(foodOrder.orderStatus){
        case OrderStatus.pending:
          status = 'Pending';
          break;
        case OrderStatus.processing:
          status = 'Processing';
          break;
        case OrderStatus.completed:
          status = 'Completed';
          break;
      }

      if(isCompleteOnly && foodOrder.orderStatus!=OrderStatus.completed) return const SizedBox();
      if(!isCompleteOnly && foodOrder.orderStatus==OrderStatus.completed) return const SizedBox();

      return ListTile(
        title: Text('ORDER #${foodOrder.orderNumber}', style: TextStyle(color: foodOrder.isVipOrder? Colors.redAccent : Colors.black),),
        subtitle: Text(foodOrder.createdAt),
        trailing: Text(status),
      );
    }
    
    
    return ListView.builder(
      itemCount: totalOrderList.length,
      padding: const EdgeInsets.only(bottom: 50.0),
      itemBuilder: (context, index)=>wFoodOrder(index),
    );
  }

  /// UI TO DISPLAY COOKING BOT LIST
  Widget wCookingBotList(){

    Widget wCookingBot(int index){
      CookingBot cookingBot = botList[index];

      String status = '';
      switch(cookingBot.botStatus){
        case BotStatus.processing:
          status = 'Processing';
          break;
        case BotStatus.idle:
          status = 'Idle';
          break;
      }

      return ListTile(
        title: Text('BOT $index'),
        trailing: Text(status),
      );
    }


    return ListView.builder(
      itemCount: botList.length,
      padding: const EdgeInsets.only(bottom: 50.0),
      itemBuilder: (context, index)=>wCookingBot(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// MAIN SCREEN UI, USE TAB CONTROL TO SEE BOT LIST OR ORDER LIST
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
        title: const Text('McDonald 2023'),
        backgroundColor: Colors.teal,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          wFoodOrderList(),
          wFoodOrderList(isCompleteOnly: true),
          wCookingBotList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('Action'),
        onPressed: () async{
          /// CHOICE ACTION BETWEEN NORMAL ORDER, VIP ORDER, ADD BOT OR MINUS BOT
          int choice = await showMyDialog(context, wPopup(
            height: 220.0,
            child: Column(
              children: [
                const Text('Choose Option', textScaleFactor: 1.25, style: TextStyle(color: Colors.white),),
                const SizedBox(height: 10.0,),
                wChoiceButton('New Normal Order', () => Navigator.of(context).pop(1)),
                wChoiceButton('New VIP Order', () => Navigator.of(context).pop(2)),
                wChoiceButton('+ Bot', () => Navigator.of(context).pop(3)),
                wChoiceButton('- Bot', () => Navigator.of(context).pop(4)),
              ],
            ),
          ));

          switch(choice){
            case 1:
              FoodOrder foodOrder = FoodOrder();
              foodOrder.orderNumber = orderNumberIncrement;
              orderList.add(foodOrder);
              orderNumberIncrement++;
              break;
            case 2:
              FoodOrder foodOrder = FoodOrder();
              foodOrder.orderNumber = orderNumberIncrement;
              foodOrder.isVipOrder = true;
              vipOrderList.add(foodOrder);
              orderNumberIncrement++;
              break;
            case 3:
              botList.add(CookingBot());
              break;
            case 4:
              if(botList.isEmpty) break;

              /// BEFORE REMOVE, CHECK PROCESS MAP IF LAST BOT IS PROCESSING ANY ORDER
              /// IF YES, CHANGE THE ORDER BACK TO PENDING, THEN REMOVE THE LAST BOT
              if(botProcessMap[botList.last.botId]!=null){
                List totalOrderList = [...vipOrderList, ...orderList];
                for(FoodOrder foodOrder in totalOrderList){
                  if(foodOrder.orderNumber == botProcessMap[botList.last.botId]){
                    foodOrder.orderStatus = OrderStatus.pending;
                    break;
                  }
                }
              }
              botList.removeLast();
              break;
          }

          setState(() {});
        },
      ),
    );
  }
}
