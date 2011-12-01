package  {
	
	import flash.display.MovieClip;
	import fl.controls.Button;
	import flash.display.Scene;
	import flash.events.MouseEvent;
	import fl.controls.Label;
	import flash.events.*;
	import flash.net.*;
	
	//This is the Main file. It handles all the meta game operations such as creating the game and saving the leaderboard.
	public class MainGame extends MovieClip {
		
		private var mineFieldOptions:Array;
		private var minesCreator:CreateMines;
		
		private var LeaderBoard:Array;
		private var leader_board_label:Label;
		
		private var info_display:Label;
		
		private var TILE_OPTIONS:Array = new Array(5,7,10);
		
		private var isFirstRun;
		
		private var phpLoader:URLLoader;
		private var phpRequest:URLRequest;
		private var phpVariables:URLVariables;
		
		private var temp_string:String;
	
		public function MainGame() {
			
			isFirstRun = true;
			mineFieldOptions = new Array();
			info_display = new Label();
			addChild(info_display);
			info_display.x = 0;
			info_display.y = 10;
			info_display.width = stage.stageWidth;
			info_display.height = stage.stageHeight;
			info_display.text = "\t\tSave your neighborhood from exploding! A neighbor gang wants to take its revenge.You have to\n\n\t\t\t\t\taccurately detect all the mines they have planted, else you are History!\n\n\n\t  You have help from your informants, They have flagged areas with mines for you.But can you trust them?\n\n\t\t\t\t\t\tSelect the appropraite size of your neighborhood and be safe!\n\n\n\t\t\t B = BOMB\t\t\t\t\t F = USE THE MOUSE WHEEL TO SET A FLAG ON AN AREA\n\n\t\t\tNUMBERS ON AN AREA DEPICT THE MINES AROUND THAT AREA";
		
			for(var i:int =0; i<TILE_OPTIONS.length ; i++){
				mineFieldOptions[i] = new Button();
				mineFieldOptions[i].name = TILE_OPTIONS[i];
				//trace(mineFieldOptions[i].name);
				mineFieldOptions[i].label= TILE_OPTIONS[i].toString() + " X " + TILE_OPTIONS[i].toString();
				addChild(mineFieldOptions[i]);
				mineFieldOptions[i].x = stage.stageWidth/2 + (150 * i) -180;
				mineFieldOptions[i].y = 230;
				mineFieldOptions[i].width =  55
				mineFieldOptions[i].height = 35;
				mineFieldOptions[i].addEventListener(MouseEvent.CLICK, generateMineField);
			}
			
			leader_board_label = new Label();
			leader_board_label.x = 20;
			leader_board_label.y = 290;
			leader_board_label.height = 200;
			leader_board_label.width = 300;
			addChild(leader_board_label);
			
			//Initializations for php
			//We use variables to exchange the backend data.
			phpVariables = new URLVariables();
			
			//These are to initialze the php values.
			//We dont need this once the php values are initialzed.
			
			phpVariables.player_name_0 = "John";
			phpVariables.player_name_1 = "Matt";
			phpVariables.player_name_2 = "Jack";
			phpVariables.player_name_3 = "Bob";
			phpVariables.player_name_4 = "Dough";
			
			phpVariables.player_score_0 = "-300";
			phpVariables.player_score_1 = "-300";
			phpVariables.player_score_2 = "-300";
			phpVariables.player_score_3 = "-300";
			phpVariables.player_score_4 = "-300";
			
			//PHP file at the host location
			phpRequest = new URLRequest("http://santosantonio.com/animish/Leader.php");
			phpRequest.method = URLRequestMethod.POST;
			phpRequest.data = phpVariables;
			
			phpLoader = new URLLoader();
			phpLoader.dataFormat = URLLoaderDataFormat.VARIABLES; 
			phpLoader.addEventListener(Event.COMPLETE, loadPHPLeaderboard);
			phpLoader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			phpLoader.load(phpRequest);
		}
		
		
		//Loads the variables from php on successful load(request);
		private function loadPHPLeaderboard(event:Event){
			trace(event.target.data.return_name_0 +" : "+ event.target.data.return_score_0);
			trace(event.target.data.return_name_1 +" : "+ event.target.data.return_score_1);
			trace(event.target.data.return_name_2 +" : "+ event.target.data.return_score_2);
			trace(event.target.data.return_name_3 +" : "+ event.target.data.return_score_3);
			trace(event.target.data.return_name_4 +" : "+ event.target.data.return_score_4);
			
			if(isFirstRun){
				isFirstRun = false;
				LeaderBoard = new Array();
				LeaderBoard[0] = new Player(event.target.data.return_name_0,int(event.target.data.return_score_0));
				LeaderBoard[1] = new Player(event.target.data.return_name_1,int(event.target.data.return_score_1));
				LeaderBoard[2] = new Player(event.target.data.return_name_2,int(event.target.data.return_score_2));
				LeaderBoard[3] = new Player(event.target.data.return_name_3,int(event.target.data.return_score_3));
				LeaderBoard[4] = new Player(event.target.data.return_name_4,int(event.target.data.return_score_4));
			}
			displayLeaders();
		}
		
		//Erroe Handler if failed to Read the php file
		private function handleIOError(event:IOErrorEvent){
			trace("ERROR:" + event.target.data);
		}
		
		//Checks if the current Player Score is higher that the leaderboard
		public function updateLeaderBoard(c_player:Player){
			for(var i:int;i<LeaderBoard.length;i++){
				if(LeaderBoard[i].getPlayerScore() < c_player.getPlayerScore()){
					pushNewPlayerInArray(c_player,i);
					break;
				}
			}
		}
		
		//Saves the new leaderboard after adjusting the places.
		private function saveLeaderboard(){
			phpVariables.player_name_0 = LeaderBoard[0].getPlayerName();
			phpVariables.player_name_1 = LeaderBoard[1].getPlayerName();
			phpVariables.player_name_2 = LeaderBoard[2].getPlayerName();
			phpVariables.player_name_3 = LeaderBoard[3].getPlayerName();
			phpVariables.player_name_4 = LeaderBoard[4].getPlayerName();
			
			phpVariables.player_score_0 = LeaderBoard[0].getPlayerScore().toString();
			phpVariables.player_score_1 = LeaderBoard[1].getPlayerScore().toString();
			phpVariables.player_score_2 = LeaderBoard[2].getPlayerScore().toString();
			phpVariables.player_score_3 = LeaderBoard[3].getPlayerScore().toString();
			phpVariables.player_score_4 = LeaderBoard[4].getPlayerScore().toString();
			
			phpLoader.load(phpRequest);
			
		}
		
		//Pushes the player in the leaderboard array and adjust the other entry positions.
		private function pushNewPlayerInArray(c_Player:Player,position:int){
			var m_position = position;
			var l_position = LeaderBoard.length -1;
			while(m_position != l_position){
				LeaderBoard[l_position] = LeaderBoard[l_position -1];
				l_position--;
			}
			LeaderBoard[m_position] = c_Player;
			saveLeaderboard();
		}
		
		//Displays the leaderboard on the flash file.
		private function displayLeaders(){
			var text_to_display:String = new String();
			text_to_display = "Top Scorers : \n";
			for (var i:int ; i<LeaderBoard.length ; i++){
				text_to_display += "\t\t\t" + LeaderBoard[i].getPlayerName() + " : " + LeaderBoard[i].getPlayerScore()+ "\n";
			}
			leader_board_label.text = text_to_display ;
		}
		
		//Generates a CreateMines object which is the speaker between the main game and the individual mines.
		private function generateMineField(event:MouseEvent){
			for(var i:int =0; i<mineFieldOptions.length ; i++){
				mineFieldOptions[i].visible = false;
			}
			info_display.visible = false;
			minesCreator = new CreateMines(event.currentTarget.name,this);
		}
		
		//Resets everything on game restart.
		public function restartMainMenu(){
			for(var i:int =0; i<mineFieldOptions.length ; i++){
				mineFieldOptions[i].visible = true;
			}
			info_display.visible = true;
			displayLeaders();
		}

	}
	
}

