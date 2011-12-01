package  {
	import flash.utils.Dictionary;
	import flash.display.MovieClip;
	import fl.controls.Button;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.text.*;
	
	//This class handles all the indivdual mines. Depending on the type of mine it will send back information
	//to the speaker class i.e CreateMines which handles all the ingame functions.
	//Each individual mine area has pointer to its neighbors, which helps in game operations such as revealing itself,
	//deciding how many live mines are around that area and unrevealing all the congruent empty mines at one go.// 
	public class Mine extends Sprite {
		
		private var index_i:int;
		private var index_j:int;
		
		private var mainGame:MainGame;
		private var createMines:CreateMines;
		
		private var neighbors:Dictionary;
		
		public var button:Button;
		
		public var mineValue:String;
		
		public var isRevealed:Boolean;
		private var isFlagged:Boolean;
		
		private var format:TextFormat;
		
		public static const HAZARDOUS_MINE = "B";
		public static const EMPTY_MINE = " ";
		public static const FLAG_MINE = "F";
		
		private const NeighborList:Array = new Array("topleft","top","topright","left","right","bottomleft","bottom","bottomright");
		
		//Initializer for each individual mine.
		public function Mine(i:int,j:int,MINES_SIZE:int,p_mainGame:MainGame,p_createMines:CreateMines) {
			index_i = i;
			index_j = j;
			
			mainGame = p_mainGame;
			createMines = p_createMines;
			
			format = new TextFormat();
			format.size = 18;
			format.bold = true;
			format.font="Handwriting - Dakota";
			
			button = new Button();
			//button.label = i.toString() + "," + j.toString();
			mineValue = null;
			button.label = " ";
			button.y = 20 + j*(MINES_SIZE+3);
			button.x =160 + i*(MINES_SIZE+3);
			button.width = MINES_SIZE;
			button.height = MINES_SIZE;
			
			mainGame.addChild(button);
			
			isRevealed = false;
			isFlagged = false;
			
			neighbors = new Dictionary();
			for(var t:int = 0; t < NeighborList.length ; t++){
				neighbors[NeighborList[t]] = null;	
			}
			
			button.addEventListener(MouseEvent.CLICK,revealSelf);
			button.addEventListener(MouseEvent.MOUSE_WHEEL,setMineToMaybe);
		}
		
		//This function assesses the neighbors of this area and depending on that decides the value of the mine.
		public function assessNeighbors(){
			var temp_s:String = mineValue;
			if(mineValue == null){
				var max_length:int = createMines.mineFieldLength;
				var hazardMines:int = 0;
				for(var s:String in neighbors){
					switch(s){
						case "topleft":
							if(index_i-1 < 0 || index_j-1 <0 ){}
							else{
								neighbors[s] = createMines.getMineField(index_i-1,index_j-1);
							}
							break;
						
						case "top":
							if(index_j-1<0){}
							else{
								neighbors[s] = createMines.getMineField(index_i,index_j-1);
							}
							break;
							
						case "topright":
							if(index_i+1 == max_length  || index_j-1 <0 ){}
							else{
								neighbors[s] = createMines.getMineField(index_i+1,index_j-1);
							}
							break;
							
						case "left":
							if(index_i-1 < 0){}
							else{
								neighbors[s] = createMines.getMineField(index_i-1,index_j);
							}
							break;
						
						case "right":
							if(index_i+1 == max_length){}
							else{
								neighbors[s] = createMines.getMineField(index_i+1,index_j);
							}
							break;
						
						//EDIT FROM HERE
						
						case "bottomleft":
							if(index_i-1 < 0 || index_j+1 == max_length ){}
							else{
								neighbors[s] = createMines.getMineField(index_i-1,index_j+1);
							}
							break;
						
						case "bottom":
							if(index_j+1 == max_length ){}
							else{
								neighbors[s] = createMines.getMineField(index_i,index_j+1);
							}
							break;
						
						case "bottomright":
							if(index_i+1 == max_length || index_j+1 == max_length){}
							else{
								neighbors[s] = createMines.getMineField(index_i+1,index_j+1);
							}
							break;
					}
					if(neighbors[s] != null && neighbors[s].getMineValue() == HAZARDOUS_MINE){
						hazardMines++;
					}
				}
				updateMineValue(hazardMines.toString());
			}
		}
		
		//Mouse Event function when a mine area is clicked.
		public function revealSelf(event:MouseEvent){
			unvielMineContents();
		}
		
		//Depending on the state of the game and the value of the mine being clicked, this area decides 
		//what operations are to be performed.
		//All empty congruent mines are revealed at once and score is updated.
		//If the game is ingame and the mine is non-hazardous, it is revealed and score is updated
		//If the game is ingame and the mine is hazardous, then the game is ended and the score is appropriately ended.
		//If the game is over the all the mines are revealed irrespective of what information it holds.
		public function unvielMineContents(gameState:String = "ingame"){
			if(!isRevealed){	
				isRevealed = true;
				if(mineValue == "0"){
					button.label = EMPTY_MINE;
					if(gameState == "ingame"){
						unvielEmptyNieghborMines();
						createMines.updateScore(CreateMines.EMPTY_MINE_SCORE);
					}
				}
				else{
					if(mineValue == HAZARDOUS_MINE){
						if(gameState == "ingame"){
							createMines.DiableAllButtons("lose");
							createMines.updateScore(CreateMines.HAZARD_MINE_SCORE);
							var current_player:Player = new Player(createMines.player_name.text,createMines.gameScore);
							mainGame.updateLeaderBoard(current_player);
						}
					}
					else{
						if(createMines.checkGameState()){
							if(gameState == "ingame"){
							createMines.DiableAllButtons("win");
								createMines.updateScore(CreateMines.WINNING_SCORE);
								var current_player:Player = new Player(createMines.player_name.text,createMines.gameScore);
								mainGame.updateLeaderBoard(current_player);
							}
						}
						else{
							if(gameState == "ingame"){
								createMines.updateScore(int(mineValue) * CreateMines.BENIGN_MINE_SCORE);
							}
						}
					}
					button.label = mineValue;
				}
				if(gameState == "ingame"){
					button.enabled = false;
					button.emphasized = true;
					
				}
			}
		}
		
		//recursovely unviels all the congruent neighbors
		private function unvielEmptyNieghborMines(){
			for(var s:String in neighbors){
				if(neighbors[s] != null){
					if(neighbors[s].getMineValue() == "0" && neighbors[s].isRevealed == false){
						neighbors[s].unvielMineContents();
					}
				}
			}
		}
		
		//MouseEvent to set a flag on a mine
		public function setMineToMaybe(event:MouseEvent){
			setMineFlag();
		}
		
		public function setMineFlag(){
			if(!isRevealed){
				if(!isFlagged){
					button.label = FLAG_MINE;
					isFlagged = true;
				}
				else{
					button.label = " ";
					isFlagged = false;
				}
			}
		}
		
		public function updateMineValue(mValue:String = HAZARDOUS_MINE){
			mineValue = mValue;
		}
		
		public function getMineValue():String{
			return mineValue;
		}
	}
	
}
