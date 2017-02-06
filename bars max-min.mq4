//+------------------------------------------------------------------+
//|                                                 bars max-min.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//объявляем переменную для мин цены
double minprice= 999999, mp, maxprice = -999999, SL, TP;
//количество баров вводимое пользователем,
// среди которых ищут максимальную и минимальную цену
extern int    BarCount   = 10;
//чтобы ордера выставлялись в определенное время - в 11 часов
extern int    HourStart  = 11;
extern double Lots       = 0.1;
extern int    StopLoss   = 100;
extern int    TakeProfit = 300;
//чтобы отличить ордера советника от других ордеров вводят номер
extern int    Magic      = 12345;
int ticket;
//+-----------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+----------------------------------------------------------
  void OnTick()
  {
     GetMinPrice();
     GetMaxPrice();
     if (TimeHour(TimeCurrent()) == HourStart)
       {
       if (BuyLimitCount() == 0 && BuyCount() == 0) 
         {
         //ордер на покупку
         //расчет стоплосс
         SL = NormalizeDouble(minprice - StopLoss*Point,5);
         //расчет тэйкпрофит
         TP = NormalizeDouble(minprice + TakeProfit*Point,5);
         ticket = OrderSend(Symbol(), OP_BUYLIMIT, Lots, minprice, 3, SL, TP, " ", Magic, 0, Blue);
         if (ticket < 0)
         //сообщить в журнале
         Print("Не удалось открыть лимитный ордер на покупку!");
         }
  
         if ( SellLimitCount() == 0 && SellCount() ==0 )
         {
         //ордер на продажу
         //расчет стоплосс
         SL = NormalizeDouble(maxprice + StopLoss*Point,5);
         //расчет тэйкпрофит
         TP = NormalizeDouble(maxprice - TakeProfit*Point,5);
         ticket = OrderSend(Symbol(), OP_SELLLIMIT, Lots, maxprice, 3, SL, TP, " ", Magic, 0, Red);
         if (ticket < 0)
         //сообщить в журнале
         Print("Не удалось открыть лимитный ордер на продажу!");
         }
       }
       Comment("MinPrice:" + DoubleToStr(minprice,5) + "/n" + "Maxprice:" + DoubleToStr(maxprice,5));
  }
//+-------------------------------------------------------------------------------------------+
//пишем функцию проверку количества ордеров 
//на покупку- ф-ия возвращает число установленных ордеров
int BuyLimitCount()
 {
 //перебрать все ордира в цикле и сравнить с buy limit
 int count = 0;
 for (int i = OrdersTotal()-1; i >= 0; i--)
   { 
   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true &&
      OrderMagicNumber() == Magic &&
      OrderType() == OP_BUYLIMIT)
       {
       count++;
       }
   }
   return(count);
 }
//+------------------------------------------------------------------+
int BuyCount()
 {
 //перебрать все ордера в цикле и сравнить с buy limit
 int count = 0;
 for (int i = OrdersTotal()-1; i >= 0; i--)
  { 
  if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true &&
     OrderMagicNumber() == Magic &&
     OrderType() == OP_BUY)
       {
       count++;
       }
   }
   return(count);
  }

//+------------------------------------------------------------------+
//пишем функцию проверку количества ордеров 
//на продажу- ф-ия возвращает число установленных ордеров
int SellLimitCount()
  {
  //перебрать все ордира в цикле и сравнить с sell limit
  int count = 0;
  for (int i = OrdersTotal()-1; i >= 0; i--)
  {
  if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true &&
     OrderMagicNumber() == Magic &&
     OrderType() == OP_SELLLIMIT)
       {
       count++;
       }
   }
   return(count);
  }

//+------------------------------------------------------------------+
int SellCount()
  {
  //перебрать все ордера в цикле и сравнить с sell limit
  int count = 0;
  for (int i = OrdersTotal()-1; i >= 0; i--)
    { 
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true &&
       OrderMagicNumber() == Magic &&
       OrderType() == OP_SELL)
         {
         count++;
         }
     }
     return(count);
    }
//+------------------------------------------------------------------+
//создаем функцию для минимума
void GetMinPrice()
{
  for (int i=0; i < BarCount; i++)
  { 
  // минимальная цена за 10 баров
  mp = iLow(Symbol(),PERIOD_CURRENT,i);
  // сравниваем значение mp и  minprice
  if ( mp < minprice )
  minprice = mp;
  }
  return;
}
//+--------------------------------------+
//создаем функцию для максимума
void GetMaxPrice()
{
// максимальная цена за 10 баров
  for ( int i=0; i < BarCount; i++)
  {
  // максимальная цена за 10 баров
  mp = iHigh(Symbol(), PERIOD_CURRENT, i);
  if ( mp > maxprice)
  maxprice = mp;
  }
  return;

}

//+---------------------------------------+
