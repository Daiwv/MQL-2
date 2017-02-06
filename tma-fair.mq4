//+------------------------------------------------------------------+
//|                                                     TMA_FAIR.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
//вводим проскальзывание
extern int Slipage =3;
//-------------------------------------------------------------------
extern string TMA                  = "Параметры индикатора TMA";
extern string TimeFrame            = "Current time frame";
extern int    HalfLength           = 56;
extern int    Price                = PRICE_CLOSE;
extern double ATRMultiplier        = 2.0;
extern int    ATRPeriod            = 100;
//чем больше параметр ATRPeriod тем плавнение сглаживание линий боленджера на графике
extern bool   Interpolate          = true;
//--------------------------------------------------------------------
extern string TMA_FAIR   = "Параметры советника TMA_FAIR";
//устанавливаем объем сделки
extern double lots                 = 0.1;
//TakeProfit(количество пуктов прибыли) для 4-х значных счетов
extern int TakeProfit              = 300;
//StopLoss(количество пунктов- оганичение потерь)для 4-х значных счетов
extern int StopLoss                = 50;
//Magic -(индивидуальная) номерация для сделки
extern int Magic                   =111;
//----------------------------------------------------------------------
double PriceHigh, PriceLow, SL, TP;
int ticket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  //перевод TakeProfit,StopLose и Slipage  для 5-ти значных счетов
  if (Digits ==3 || Digits ==5)
  {
  TakeProfit*=10;
  StopLoss*=10;
  Slipage*=10;
  }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  //функция iCostum- вызывается каждый раз при получении котировок
  //объявляем верхнюю границу канала
  PriceHigh = iCustom(NULL,0,"TMA_FAIR", TimeFrame, HalfLength, Price, ATRMultiplier, ATRMultiplier, ATRPeriod, Interpolate, 1, 0); 
   //объявляем нижнюю границу канала 
  PriceLow = iCustom(NULL,0,"TMA_FAIR", TimeFrame, HalfLength, Price, ATRMultiplier, ATRMultiplier, ATRPeriod, Interpolate, 2, 0); 
  if ( CountBuy() == 0 && Ask >= PriceLow )
    {
    //открываем ордер на покупку
    ticket = OrderBuy(Symbol(), OP_BUY, lots, Ask, Slipage, 0, 0, "TMA ROBOT", Magic, 0, Green);
    
    if (ticket>0)
    // расчет TP и SL
      {
      TP = NormalizeDouble(Ask + TakeProfit*Point, Digits);
      SL = NormalizeDouble(Ask - StopLoss*Point, Digits);
      //модифицируем ордер
      if (OrderSelect(ticket, SELECT_BY_TICKET))
      
      if (!OrderModify(ticket, OrderOpenPrice(), SL, TP, 0))
      Print("Ошибка модификации ордера на покупку!");
       
      else Print("Ошибка открытия ордера на покупку!")
      //---------------------------------------------------------
      if ( Ask <= PriceLow && CountSell() > 0)
      {
        for ( int i = OrderTotal()-1, i >= 0, i--)
        {
        if OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
          {
          if ( OrderMagicNumber() == Magic && OrderType() == OP_SELL)
          {
          OrderClose(!OrderTicket(), OrderLots(), Ask, Slipage, Black);
          Print("Ошибка модификации ордера на продажу!");
          }
        
      }
    }  
      
 
 
  if ( CountSell() == 0 && Bid >= PriceHigh )
    {
    //открываем ордер на продажу
    ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, Slipage, 0, 0, "TMA ROBOT", Magic, 0, Red);
    }
    if ( ticket > 0 )
    // расчет TP и SL
      {
      SL = NormalizeDouble(Bid + StopLoss*Point, Digits);
      TP = NormalizeDouble(Bid - TakeProfit*Point, Digits);
      //модифицируем ордер
      if (OrderSelect(ticket, SELECT_BY_TICKET))
      {
      if (!OrderModify(ticket, OrderOpenPrice(), SL, TP, 0))
      {
      Print("Ошибка модификации ордера на продажу!");
       else Print("Ошибка открытия ордера на продажу!"); 
      
      
   //---------------------------------------------------
      if ( Bid <= PriceHigh && CountBuy() > 0)
      {
        for ( int i = OrderTotal()-1, i >= 0, i--)
        {
        if OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
          {
          if ( OrderMagicNumber() == Magic && OrderType() == OP_BUY)
          OrderClose(!OrderTicket(), OrderLots(), Bid, Slipage, Black);
          Print("Ошибка модификации ордера на покупку!");
          
        }
      }
    }    
 } 
  
  //--------------------------------------------------------------------
  //Опишем полностью функцию CountSell()
  int CountSell()
  {
  int count = 0;
  for (int trade = OrdersTotal()-1; trade > 0; trade--)
    {
    //перебераем ордера в цикле
     if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))
    {
    if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELL)
    
    //подсчитаем количество ордеров на продажу
    count++;
    }
    }
  return (count);
  }   
  
 //-------------------------------------------------------------------------- 
  //Опишем полностью функцию CountBuy()
  int CountBuy()
  {
  int count = 0;
  for (int trade = OrdersTotal()-1; trade > 0; trade--)
    {
    //перебераем ордера в цикле
    if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))
    {
    if ( OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY)
    
    //подсчитаем количество ордеров на покупку
    count++;
    }
    }
    return(count);
   }
   
   
   
//+------------------------------------------------------------------+
