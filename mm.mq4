//+------------------------------------------------------------------+
//|                                                           MM.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "MM"
#property version   "1.00"
#property strict
// обозначает что на 10000 базовой валюты - 
//определяем 0,1L для мартингейла
extern double lotsFor10000 = 0.1;
//заложим процент риска на депозит-чтобы из вне можно
// измененять в процентах(%)
extern double Risk = 4;
//заложим из вне  stoploss(SL)- уровень потерь в пунктах
extern int stoploss = 40;
//вводим переменную сбор информации
string comm;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//для трех и пяти значных умножаем на 10
   if (Digits==3 || Digits==5)
   stoploss*=10;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {  
  comm = comm + "Объем следующей позиции:" + DoubleToStr(LotsByRisk(OP_BUY,Risk,stoploss),2)+"\n";
  //покажем валютную пару
  comm = "Symbol:" + Symbol() + "/n";
  comm = comm + "Максимальная дневная цена:" + DoubleToStr(MarketInfo(Symbol(),MODE_HIGH),Digits)+ "\n";
  comm = comm + "Минимальная дневная цена:" + DoubleToStr(MarketInfo(Symbol(),MODE_LOW),Digits) + "\n";
  //размер пункта в валюте котировки
  comm = comm + "Размер пункта в валюте котировки:" + DoubleToStr(MarketInfo(Symbol(),MODE_POINT)) + "\n";
  comm = comm + "Количество цифр после запятой в цене инструмента:" + DoubleToStr(MarketInfo(Symbol(),MODE_DIGITS)) +"\n";
  //спред
  comm = comm + "Спред в пунктах:" + DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD)) + "\n";
  //минимальный допустимый уровень стоплоса (stoploss) и теэкпрофита (tp) в пунктах:
  comm = comm + "Минимально допустимый уровеь sl/tp в пунктах:" + DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL)) + "\n";
  //своп на покупку
  comm = comm + "Размер свопа для ордеров на покупку:" + DoubleToStr(MarketInfo(Symbol(),Digits)) + "\n";
  //своп на продажу
  comm = comm + "Размер свопа для ордеров на продажу:" + DoubleToStr(MarketInfo(Symbol(),Digits)) +"\n";
  
   
  }
//+------------------------------------------------------------------+
double GetLots()
 {
//внутренняя переменная для расчета лота clots
double clots=AccountBalance()/10000*lotsFor10000;
// максимум из двух этих чисел
clots= MathMax(clots,MarketInfo(Symbol(),MODE_MINLOT));
// минимум из двух этих чисел: сравниваем MODE_MAXLOT c clots
clots= MathMin(clots,MarketInfo(Symbol(),MODE_MAXLOT));
//clots может быть два знака после запятой
clots=NormalizeDouble(clots,2);
return(clots);
 }
//---------------------------------------------------------------------
//Напишем еще одну функцию
double LotsByRisk(double risk, int op_type, int sl)
{
//минимальный лот
double lot_min=MarketInfo(Symbol(),MODE_MINLOT);
//максимальный лот
double lot_max=MarketInfo(Symbol(),MODE_MAXLOT);
//шаг лота
double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
//стоимость одного пункта
double lot_cost=MarketInfo(Symbol(),MODE_TICKVALUE);
double lot=0;
//количество денег на один пункт 
double UsdPerPip=0;
//расчет лота
lot=AccountBalance()*risk/100;
double UsdPerPin=NormalizeDouble(lot/sl,2);
//перевод к виду Double
lot=NormalizeDouble(UsdPerPin/lot_cost,2);
lot=NormalizeDouble(lot/lot_step,0)*lot_step;
if (lot<lot_min) lot=lot_min;
if (lot>lot_max) lot=lot_max;
//проверка ошибки- хватит ли у вас средств для открытия очередного ордера
//symbol()- это валютная пара; 10-это 10 usd;lot- это объем
if (AccountFreeMarginCheck(Symbol(),op_type,lot)<10 || GetLastError() == ERR_NOT_ENOUGH_MONEY)
{
Alert ("Невозможно открыть позицию с объемом="+DoubleToStr(lot,2)," Недостаточно средств! ");
//либо нуль
return(-1);
}
//если все хорошо- возвращаем лот
return(lot);
}
