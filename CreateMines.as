package  {
	
	import flash.display.MovieClip;
	import fl.controls.Button;
	import fl.controls.Label;
	import flash.display.Scene;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.text.*;
	import fl.motion.Color;
	
	//This class conducts the actual game. It performs all the ingame operations to basically setup the game.
	//Holds all the mines in a 2*2 array,mineField. but all individual mines are a modified linked list which hold info about all their neighbors//
	public class CreateMines {
		
		private var mineField:Array;
		private var mainGame:MainGame;
		
		public var mineFieldLength:int;
		
		private var MINES_SIZE:int;
		
		private var difficultyLevel:int;
		
		private var restart_button:Button;
		private var result_display:Label;
		private var score_display:Label;
		public var player_name:TextField;
		
		private var format:TextFormat;
		
		private var numberOfHazardMines:int;
		
		public var gameScore:int;
		
		//Some Constants that dictate the game.
		public static const HAZARD_MINE_PROBABILTY = 0.6;
		public static const BENIGN_MINE_PROBABILTY = 0.9;
		
		public static const HAZARD_MINE_SCORE = -300;
		public static const BENIGN_MINE_SCORE = 10;
		public static const WINNING_SCORE = 100;
		public static const EMPTY_MINE_SCORE = 1;
		
		
		//Game initialzer
		public function CreateMines(number_of_mines:int,p_maingame:MainGame,diff:int = 10) {
			mainGame = p_maingame;
			mineFieldLength = number_of_mines;
			
			difficultyLevel = diff;
			
			//Number of hazard mines depending on the difficulty
			numberOfHazardMines = Math.ceil(mineFieldLength * mineFieldLength * difficultyLevel /100);
			
			gameScore = 0;
			
			//Dynamically decides the mine sizes
			MINES_SIZE = (mainGame.stage.stageHeight - 70) / number_of_mines;
			
			//Creates a 2*2 array and holds all the individual mines inside it.
			mineField = new Array(number_of_mines);
			for(var i:int = 0; i< mineFieldLength ; i++){
				mineField[i] = new Array(number_of_mines);
				for(var j:int = 0; j< mineFieldLength ; j++){
					mineField[i][j] = new Mine(i,j,MINES_SIZE,mainGame,this);
					//mineField[i][j] = i.toString()+j.toString();
				}	
			}
			
			//Randomly decides the hazardous mines
			assignHazardMineValues();
			
			//Makes all the individual mines assess their neighbors.
			for(var i:int = 0; i< mineFieldLength ; i++){
				for(var j:int = 0; j< mineFieldLength ; j++){
					mineField[i][j].assessNeighbors();
				}	
			}
			
			//This functions serves the game design choice that some mines will have flags set on them at start indicating 
			//that they are hazardous. Not all the mines with flags are hazardous and vice a versa. This function which is again
			//a random function serves this purpose//
			setFlagsOnAreas();
			
			
			//Info labels and buttons are declared here
			format = new TextFormat();
			format.size = 13;
			format.color = 0x030303;
			format.font="Handwriting - Dakota";
			
			result_display = new Label();
			result_display.setStyle("textFormat",format);
			result_display.x = 13;
			result_display.y = 80;
			result_display.width += 50;
			setMessage("Best of Luck !");
			mainGame.addChild(result_display);
			
			player_name = new TextField();
			//player_name.setStyle("textFormat",format);
			player_name.x = 13;
			player_name.y = 110;
			player_name.width += 50;
			player_name.text = "Player";
			player_name.type = "input";
			mainGame.addChild(player_name);
			
			score_display = new Label();
			score_display.setStyle("textFormat",format);
			score_display.x = 13;
			score_display.y = 130;
			score_display.width += 50;
			updateScore(0);
			mainGame.addChild(score_display);
			
			restart_button = new Button();
			mainGame.addChild(restart_button);
			restart_button.label = "Restart";
			restart_button.x = 10;
			restart_button.y = 20;
			restart_button.addEventListener(MouseEvent.CLICK,onQuit);
		}
		
		public function updateScore(score:int){
			gameScore += score;
			score_display.text = "SCORE : " + gameScore.toString();
		}
		
		//Sets a flag on the mines at game start. It is a combo of the mine value and random number generator.
		private function setFlagsOnAreas(){
			var num_mines:int = numberOfHazardMines;
			while(num_mines >= 0){
				for(var i:int = 0; i< mineFieldLength ; i++){
					for(var j:int = 0; j< mineFieldLength ; j++){
						switch(mineField[i][j].getMineValue()){
							case "B"://If the mine is hazardous it has a higher probabilty of setting a flag.
								if(Math.random() >= HAZARD_MINE_PROBABILTY){
									mineField[i][j].setMineFlag();
									num_mines--;
								}
								break;
							case "0":
								break;
							default://If the mine is non-hazardous it has a lower probabilty of setting a flag.
								if(Math.random() >= BENIGN_MINE_PROBABILTY){
									mineField[i][j].setMineFlag();
									num_mines--;
								}
								break;
						}
					}
				}
			}
		}
		
		//Sets randomly hazardous mines
		private function assignHazardMineValues(){
			for(var i:int = 0 ; i < numberOfHazardMines ; i++){
				mineField[Math.floor(Math.random()* (1+ (mineFieldLength-1) - 0) + 0)][Math.floor(Math.random()* (1+ (mineFieldLength-1) - 0) + 0)].updateMineValue(Mine.HAZARDOUS_MINE);
			}
		}
		
		public function getMineField(index_i:int,index_j:int):Mine{
			return mineField[index_i][index_j];
		}
		
		//when the game is restarted
		private function onQuit(event:MouseEvent){
			DestroyAndRestart();
		}
		
		//resets the game and transfers control to MainGame
		public function DestroyAndRestart(){
			mainGame.removeChild(restart_button);
			mainGame.removeChild(result_display);
			mainGame.removeChild(player_name);
			mainGame.removeChild(score_display);
			for(var i:int = 0; i< mineFieldLength ; i++){
				for(var j:int = 0; j< mineFieldLength ; j++){
					mainGame.removeChild(mineField[i][j].button);
				}
			}
			mainGame.restartMainMenu();
		}
		
		//Depending on the game state it diables buttons and set the correct text message.
		public function DiableAllButtons(game_state:String){
			
			for(var i:int = 0; i< mineFieldLength ; i++){
				for(var j:int = 0; j< mineFieldLength ; j++){
					mineField[i][j].button.removeEventListener(MouseEvent.CLICK,mineField[i][j].revealSelf);
					mineField[i][j].button.removeEventListener(MouseEvent.MOUSE_WHEEL,mineField[i][j].setMineToMaybe);
				}
			}
			switch(game_state){
				case "win":
					result_display.setStyle("textFormat",format);
					setMessage("Congrats You Have Won !");
					for(var i:int = 0; i< mineFieldLength ; i++){
						for(var j:int = 0; j< mineFieldLength ; j++){
							if(!mineField[i][j].isRevealed){
								mineField[i][j].unvielMineContents("gameEnded");
							}
						}
					}
					break;
				case "lose":
					result_display.setStyle("textFormat",format);
					setMessage("Better Luck Next Time !");
					for(var i:int = 0; i< mineFieldLength ; i++){
						for(var j:int = 0; j< mineFieldLength ; j++){
							if(!mineField[i][j].isRevealed){
								mineField[i][j].unvielMineContents("gameEnded");
							}
						}
					}
					break;
				default:
					result_display.setStyle("textFormat",format);
					setMessage("Wrong state");
					break;
			}
		}
		
		public function setMessage(msg:String){
			result_display.text = msg;
		}
		
		//Checks if the game is won.
		public function checkGameState():Boolean{
			var won_flag:Boolean = true;
			for(var i:int = 0; i< mineFieldLength ; i++){
				for(var j:int = 0; j< mineFieldLength ; j++){
					if(mineField[i][j].getMineValue() != Mine.HAZARDOUS_MINE){
						var temp_b:Boolean = mineField[i][j].isRevealed;
						if(mineField[i][j].isRevealed){
							won_flag = true;
						}
						else{
							won_flag = false;
							i = mineFieldLength;
							j = mineFieldLength;
						}
					}
				}	
			}
			return won_flag;
		}

	}
	
}
