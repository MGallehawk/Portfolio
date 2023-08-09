function calculate(){
    var heightInput = document.querySelector(".height-input-feild");
    var weightInput = document.querySelector(".weight-input-feild");
    var calculateButton = document.querySelector(".calculate");
    var result = document.querySelector(".result");
    var statement = document.querySelector(".result-statement");
    var height = heightInput.value;
    var weight = weightInput.value;
    var BMI = weight/(height**2);

    result.innerText = "BMI = " + BMI;
    if(BMI < 18.5){
        statement.innerText = "Your BMI falls within the Underweight range";
    }else if ((BMI > 18.5)&&(BMI <24.9)){
        statement.innerText = "Your BMI falls within normal range";
    
    }else if ((BMI > 25)&&(BMI <29.9)){
        statement.innerText = "Your BMI falls within the overweight range";
    }else {
        statement.innerText = "Your BMI falls within the obese range";
    }
}