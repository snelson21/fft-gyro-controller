
float Filter1(float ValueAux,float[] ValuesArray, int Npoints, int Nfiltervalues){
  float F=0.0;
  
  
  float lastValue = ValuesArray[Npoints-1];
  float deltaValue = sqrt(pow((ValueAux- lastValue),2));
  
  float MaxValueR = ValueAux;
  if(lastValue>ValueAux){
    MaxValueR = lastValue;
  }
  
  float RateError = (deltaValue/MaxValueR)*100.0;
  
  if(RateError>60){
    
    F = lastValue;
    
  }else{
    
    //println("++++++++++++++++++++++++++++++++++++++");
    float Suma = 0;
    int idx= Npoints-Nfiltervalues;
    for(int i=0;i<Nfiltervalues-1;i++){
      Suma = Suma + ValuesArray[idx];
      idx++;
      //println(i + ".- " + ValuesArray[idx]);
    }    
    Suma= (Suma + ValueAux);
    
    F = Suma /(float)Nfiltervalues;
    
    
    
  }
  
  //println("ValueAux:" + ValueAux + "  last value:" + lastValue +  " F:" + F  + " Rate Error: " + RateError + " Max Value Relative: " + MaxValueR);
  return F;
}



float Filter2(float ValueAux,float[] ValuesArray, int Npoints, int Nfiltervalues){
  float F=0.0;
    
  float lastValue = ValuesArray[Npoints-1];
  float deltaValue = sqrt(pow((ValueAux- lastValue),2));
  
  float MaxValueR = ValueAux;
  if(lastValue>ValueAux){
    MaxValueR = lastValue;
  }
  
  float RateError = (deltaValue/MaxValueR)*100.0;
    
  //println("++++++++++++++++++++++++++++++++++++++");
  /*if(RateError>90){
    F=ValueAux;
  }else{*/
    float Suma = 0;
    int idx= Npoints-Nfiltervalues;
    for(int i=0;i<Nfiltervalues-1;i++){
      Suma = Suma + ValuesArray[idx];
      idx++;
      //println(i + ".- " + ValuesArray[idx]);
    }    
    Suma= (Suma + ValueAux);    
    F = Suma /(float)Nfiltervalues;
  //}
  
    
  //println("ValueAux:" + ValueAux + "  last value:" + lastValue +  " F:" + F  + " Rate Error: " + RateError + " Max Value Relative: " + MaxValueR);
  
  return F;
}
