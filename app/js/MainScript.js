$(document).ready(function () {
  //Login Code Start
  var Done =false;//used for animation
  $("#login").click(function(e) {
    e.preventDefault(); //prevent the page from refreshing
    var Username = document.getElementById("user").value;
    var pass = document.getElementById("pass").value;
    var Good = VerifyLogin(Username,pass);
    if(Good)
    {
    if (EmbarkJS.isNewWeb3()) 
     {
      Slots.methods.Login(Username,pass).call({from: web3.eth.defaultAccount,gas:3000000},function(err, value) {
        alert(value);
        if(value)
        {
          //location.replace("/SlotsonTheBlock/dist/HtmlPages/MainMenu.html");
          document.getElementById("Main").style.display="none";
          document.getElementById("pick").style.display="block";
          InitSlotMachine("Sphamandla");
        }
        else
        {
          alert("Incorrect Username or Password");
        }
       });// Setup the game board etc..   
     }
     else
     {
       var value =Slots.Login(Username,pass).call();
       alert(value);//not entirely sure how i would handle checking if the login was succesfull if the user is using an older version of embarkjs
       if(value)
       {
        //location.replace("/SlotsonTheBlock/dist/HtmlPages/MainMenu.html");
        document.getElementById("Main").style.display="none";
       
      }
       else
       {
         alert("Incorrect Username or Password");
       } 
    }
    }
    else
    {
      //do something which i havent figured out yet
    }
  });
  //Login Code End

  //Signup Code  Start

  $("#signup").click(function(e) {
    e.preventDefault(); //prevent the page from refreshing
    var Username = document.getElementById("email").value;
    var pass = document.getElementById("passSignUp").value;
    var pass1 = document.getElementById("passSignUp2").value;
    
    var Good = Verify(Username,pass,pass1);
    if(Good)
    {
    if (EmbarkJS.isNewWeb3()) 
     {
       var test =web3.eth.accounts;
      Slots.methods.RegisterGambler(web3.eth.defaultAccount,Username,pass).call({from: web3.eth.defaultAccount,gas:3000000},function(err, value) {
        alert(value);
        if(value)
        {
              //location.replace("../HtmlPages/MainMenu.html");
              document.getElementById("Main").style.display="none";
          document.getElementById("Slots").style.display="block";
          document.getElementById("canvas").style.display="none";
        }
        else
        {
          alert("User Already registered please login!");
        }
       });// Setup the game board etc..   
     }
     else
     {
       var value =Slots.RegisterGambler(web3.defaultAccount,Username,pass).call();
       alert(value);//not entirely sure how i would handle checking if the login was succesfull if the user is using an older version of embarkjs
       if(value)
       {
        //location.replace("../HtmlPages/MainMenu.html");
        document.getElementById("Main").style.display="none";
      
       }
       else
       {
         alert("Incorrect Username or Password");
       }
      }
    }
    else
    {
      //do something which i havent figured out yet
    }
  });

 //Select Word Popup Start
$("#Play").click(function(e){
  e.preventDefault();
 document.getElementById("canvas").style.display="block";
 var term=$("#words").children("option").filter(":selected").text();
 if(term =="Select word to play")
 {
  alert("Please select a valid word to play");
  return;
 }
 document.getElementById("pick").style.display="none";
 var winorNot =InitSlotMachine(ReadWords());
 if(Done)
 {
 if(winorNot==term)
 {
   //10 tokens is the defualt winnings
  Slots.methods.AddToWinnings(web3.eth.defaultAccount,10,0).call({from: web3.eth.defaultAccount,gas:3000000},function(err, value) {
    alert(value);
  });
  alert("10 Dogos have been added to your account");
  document.getElementById("pick").style.display="block";
  document.getElementById("canvas").style.display="none";

 }
 else
 {
   alert("Wont you try again");
  document.getElementById("pick").style.display="block";
  document.getElementById("canvas").style.display="none";


 }
}
});
 //Select word Popup End
  //Signup Code End
  //Used to verify if password and username are correct when the user is loggin in
  function VerifyLogin (username,password)
  {
    var Good = true;
    if(username.length ==0||username=="")
    {
      alert("Username not typed in");
      return !Good;
    }
    if(password .length==0 || password =="")
    {
      alert("Please enter password");
      return !Good;
    }
    return Good;
  }


  //Used for verifying if the user has inserted all the required info for registering on the system
  function Verify(username,pass,pass1)
  {
    var Good = true;
    if(username=="" || username.length==0)
    {
      alert("Username cannot be empty");
      return !Good;
    }
    if(pass.length ==0 || pass.length=="" || pass1.length==0 || pass1 =="")
    {
      alert("Password cannot be left empty");
      return !Good;
    }
    if (pass != pass1)
    {
      alert("Passwords dont match!");
      return !Good;
    }
    if(pass.length <8 && pass1.length <8)
    {
       alert("Password length cannot be less than 8");
       return !Good;
    }
    return Good;//All Good;
  }

//MainMenu Code  Start

$(".nav-toggle").click(function() {
  $(this).toggleClass("active");
  $(".overlay-boxify").toggleClass("open")
});
$(".overlay ul li a").click(function() {
  $(".nav-toggle").toggleClass("active");
  $(".overlay-boxify").toggleClass("open")
});
$(".overlay").click(function() {
  $(".nav-toggle").toggleClass("active");
  $(".overlay-boxify").toggleClass("open")
});

//Upper case every item in the array



function UppercaseItems(items)
{
  var Items= [];
  for(var i=0; i < items.length;i++)
  {
    Items.push(items[i].toUpperCase());
  }
  return Items;
}
//MainMenu Code End
  // Slots Machine Setting Code

 function InitSlotMachine(words)
 {

var nwords =UppercaseItems(words);
var text = nwords[Math.floor((Math.random() * nwords.length) + 1)];  // The message displayed
var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';  // All possible Charactrers
var scale = 50;  // Font size and overall scale
var breaks = 0.003;  // Speed loss per frame
var endSpeed = 0.05;  // Speed at which the letter stops
var firstLetter = 220;  // Number of frames untill the first letter stopps (60 frames per second)
var delay = 40;  // Number of frames between letters stopping



var canvas = document.querySelector('canvas');
var ctx = canvas.getContext('2d');
var done =false;//used to check if animation has completed or not
var chosenText=text;
text = text.split('');
chars = chars.split('');
var charMap = [];
var offset = [];
var offsetV = [];
var loop;
var count =0;
for(var i=0;i<chars.length;i++){
  charMap[chars[i]] = i;
}

for(var i=0;i<text.length;i++){
  var f = firstLetter+delay*i;
  offsetV[i] = endSpeed+breaks*f;
  offset[i] = -(1+f)*(breaks*f+2*endSpeed)/2;
}

(onresize = function(){
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
})();

requestAnimationFrame(loop = function(){
  ctx.setTransform(1,0,0,1,0,0);
  ctx.clearRect(0,0,canvas.width,canvas.height);
  ctx.globalAlpha = 1;
  ctx.fillStyle = '#622';
  ctx.fillRect(0,(canvas.height-scale)/2,canvas.width,scale);
  for(var i=0;i<text.length;i++){
    ctx.fillStyle = '#ccc';
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'center';
    ctx.setTransform(1,0,0,1,Math.floor((canvas.width-scale*(text.length-1))/2),Math.floor(canvas.height/2));
    var o = offset[i];
    while(o<0)o++;
    o %= 1;
    var h = Math.ceil(canvas.height/2/scale)
    for(var j=-h;j<h;j++){
      var c = charMap[text[i]]+j-Math.floor(offset[i]);
      while(c<0)c+=chars.length;
      c %= chars.length;
      var s = 1-Math.abs(j+o)/(canvas.height/2/scale+1)
      ctx.globalAlpha = s
      ctx.font = scale*s + 'px Helvetica'
      ctx.fillText(chars[c],scale*i,(j+o)*scale);
    }
    offset[i] += offsetV[i];
    offsetV[i] -= breaks;
    if(offsetV[i]<endSpeed){
      offset[i] = 0;
      offsetV[i] = 0;
    }
    }

  requestAnimationFrame(loop);

});
return chosenText;
 } 

 //Funtion to read local text file with predifined words
  //Funtion to read local text file with predifined words
  function ReadWords()
  {
   var words =[
   "iron",
   "rung",
   "loan",
   "coat",
   "mood",
   "palm",
   "ruin",
   "heal",
   "side",
   "full",
   "care",
   "soft",
   "dare",
   "fuss",
   "pain",
   "weak",
   "AIDS",
   "fist",
   "sell",
   "rear",
   "pill",
   "fund",
   "goat",
   "year",
   "late",
   ];
  return words;
  }




});
  window.onload = function(e){ 
    //document.getElementById("Slots").style.display="none";
    var s =document.getElementById("id01").style.display="block";
    var s1=document.getElementById("words");
    document.getElementById("words").style.display="block";
    var words = ReadWords();
    for(var i =0; i <words.length;i++){
      var option = document.createElement("option");
      option.value=words[i];
      option.text = words[i];
      s1.appendChild(option);    
    } 

}

 //Funtion to read local text file with predifined words
 function ReadWords()
 {
  var words =[
  "iron",
  "rung",
  "loan",
  "coat",
  "mood",
  "palm",
  "ruin",
  "heal",
  "side",
  "full",
  "care",
  "soft",
  "dare",
  "fuss",
  "pain",
  "weak",
  "AIDS",
  "fist",
  "sell",
  "rear",
  "pill",
  "fund",
  "goat",
  "year",
  "late",
  ];
 return words;
 }


