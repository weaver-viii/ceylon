doc "An animate thing that can move between
     locations of its own accord (if the
     player asks nicely)."
mutable package class Creature(String name, String description, Location location,
								Natural damage, Natural agility, Natural life) 
		extends Thing(name, description, location) {
		
	package Natural damage = damage;
	package Natural agility = agility;
	package mutable Natural life = life;
		
	package void go(Adventure game, Direction direction) {
		if ( cooperative(direction) ) {
			Location newLocation = location.connection(direction);
			location.remove(this);
			newLocation.put(this);
			game.currentLocation := newLocation;
			game.display("${name} went ${direction}.");
		}
		else {
		    game.display("${name} doesn't move an inch.");
		}
	}
	
	package void kill(Adventure game, Artifact weapon) {
		do {
			Natural attack = game.random();
			if ( attack>agility ) {
				life -= weapon.damage;
				game.display("You did ${weapon.damage} points of damage.");
				
			}
			else {
				game.display("You missed.");
			}
			Natural defense = game.random();
			if ( defense+agility > game.level ) {
				game.life -= damage;
				game.display("The ${name} did ${damage} points of damage.");
				if (game.life<=0) {
					game.display("You are dead.");
				}
			}
			else {
				game.display("The ${name} missed.");
			}
		}
		while (life>0)
		game.display("You killed the ${name}.");
		dead();
	}
		
	doc "Override this to implement special 
	     rules for commanding the creature"
	package Boolean cooperative(Direction direction) {
		return true;
	}
	
	doc "Override this to do special things
	     when the creature dies (drop items, 
	     end adventure)."
	package void dead() {}
		
}
