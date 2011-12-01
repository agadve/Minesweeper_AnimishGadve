package  {
	
	
	//Abstract Datatype to hold the player info
	public class Player{
		
		private var player_name:String;
		private var player_score:int;
		private var player_rank:int; //This attribute is not used but could be if necessary in the future//
		
		public function Player(p_name:String,p_score:int){
			player_score = p_score;
			player_name = p_name;
		}
		
		public function getPlayerName():String{
			return player_name
		}
		
		public function getPlayerScore():int{
			return player_score;
		}
	}
	
}
