@test
shared void tuples() {
    [Integer,String,Singleton<Character>] returnTuple(Integer a, String b, Singleton<Character> c) {
        return [a,b,c];
    }
    value t = returnTuple(1, "2", Singleton('3'));
    alias Triplet => [Integer,String,Singleton<Character>];
    Triplet? subt = t;
    check(subt is Triplet, "tuples");
    check(t.lastIndex == 2, "tuple lastIndex");
    Integer v1 = t[0];
    String v2 = t[1];
    Singleton<Object> v3 = t[2];
    Integer t1 = t.first;
    check(t1 == 1, "tuples first");
    String t2 = t.rest.first;
    check(t2 == "2", "tuple rest.first");
    Singleton<Character> t3 = t.rest.rest.first;
    check(t3.first == '3', "tuple rest.rest.first");
    check(t.reversed.sequence() == {Singleton('3'),"2",1}.sequence(), "tuple reversed `` t.reversed.sequence() ``");
    check(t[-2..-1] == {}, "tuple[-2..-1] `` t[-2..-1] ``, should be empty");
    check(t[-2..0] == {1}.sequence(), "tuple[-2..0] `` t[-2..0] ``");
    check(t[0..1] == {1,"2"}.sequence(), "tuple[0..1] `` t[0..1] ``");
    check(t[1..2] == {"2",{'3'}.sequence()}.sequence(), "tuple[1..2] `` t[1..2] ``");
    check(t[2..2] == [['3']], "tuple[2..2] `` t[2..2] ``");
    check(t[2..3] == [['3']], "tuple[2..3] `` t[2..3] ``");
    check(t[2..1] == {{'3'}.sequence(),"2"}.sequence(), "tuple[2..1] `` t[2..1] ``");
    check(t[1..0] == {"2",1}.sequence(), "tuple[1..0] `` t[1..0] ``");
    check(t[-2..6] == {1,"2",{'3'}.sequence()}.sequence(), "tuple[-2..6] `` t[-2..6] ``");
    check(t[5..6] == {}, "tuple[5..6] `` t[5..6] ``");
    
    check(t[0:0] == {}, "tuple[0] `` t[0] ``");
    check(t[0:2] == {1,"2"}.sequence(), "tuple[0:2] `` t[0:2] ``");
    check(t[1:2] == {"2",{'3'}.sequence()}.sequence(), "tuple[1:2] `` t[1:2] ``");
    check(t[2:1] == [['3']], "tuple[2:1] `` t[2:1] ``");
    
    check(t[-1...] == {1,"2",{'3'}.sequence()}.sequence(), "tuple[-1...] `` t[-1...] ``");
    check(t[0...] == {1,"2",{'3'}.sequence()}.sequence(), "tuple[0...] `` t[0...] ``");
    check(t[1...] == {"2",{'3'}.sequence()}.sequence(), "tuple[1...] `` t[1...] ``");
    check(t[2...] == [['3']], "tuple[2...] `` t[2...] ``");
    check(t[3...] == {}, "tuple[3...] `` t[3...] ``");
    check(t[...-1] == {}, "tuple[...-1] `` t[...-1] ``");
    check(t[...0] == {1}.sequence(), "tuple[...0] `` t[...0] ``");
    check(t[...1] == {1, "2"}.sequence(), "tuple[...1] `` t[...1] ``");
    check(t[...2] == {1, "2", {'3'}.sequence()}.sequence(), "tuple[...2] `` t[...2] ``");
    check(t[...3] == {1, "2", {'3'}.sequence()}.sequence(), "tuple[...3] `` t[...3] ``");
    //Check inherited methods work
    check(1 in t, "tuple contains");
    check(t.find((Object x) => x is Integer) exists, "tuple find");
    check(t.any((Object x) => x is String), "tuple any");
    check(t.every((Object x) => true), "tuple every");
    check(t.count((Object x) => x is String) == 1, "tuple count");
    
    "Helper for testing tuples with tails"
    void with123([Integer, Integer, Integer+] t, String msg) {
        alias Triplet => [Integer,Integer,Integer+];
        Triplet? subt = t;
        check(subt is Triplet, "``msg``: tuples");
        check(t.lastIndex == 2, "``msg``: tuple lastIndex");
        Integer v1 = t[0];
        Integer v2 = t[1];
        Integer  v3 = t[2];
        Integer t1 = t.first;
        check(t1 == 1, "``msg``: tuples first");
        Integer t2 = t.rest.first;
        check(t2 == 2, "``msg``: tuple rest.first");
        Integer t3 = t.rest.rest.first;
        check(t3 == 3, "``msg``: tuple rest.rest.first");
        Integer[] t4 = t.rest.rest.rest;
        check(t4.empty, "``msg``: tuple rest.rest.rest");
        check(t.reversed.sequence() == {3,2,1}.sequence(), "``msg``: tuple reversed `` t.reversed.sequence() ``");
        check(t[-2..-1] == {}, "``msg``: tuple[-2..-1] `` t[-2..-1] ``, should be empty");
        check(t[-2..0] == {1}.sequence(), "``msg``: tuple[-2..0] `` t[-2..0] ``");
        check(t[0..1] == {1,2}.sequence(), "``msg``: tuple[0..1] `` t[0..1] ``");
        check(t[1..2] == {2,3}.sequence(), "``msg``: tuple[1..2] `` t[1..2] ``");
        check(t[2..2] == [3], "``msg``: tuple[2..2] `` t[2..2] ``");
        check(t[2..3] == [3], "``msg``: tuple[2..3] `` t[2..3] ``");
        check(t[2..1] == {3,2}.sequence(), "``msg``: tuple[2..1] `` t[2..1] ``");
        check(t[1..0] == {2,1}.sequence(), "``msg``: tuple[1..0] `` t[1..0] ``");
        check(t[-2..6] == {1,2,3}.sequence(), "``msg``: tuple[-2..6] `` t[-2..6] ``");
        check(t[5..6] == {}, "``msg``: tuple[5..6] `` t[5..6] ``");
        
        check(t[0:0] == {}, "``msg``: tuple[0] `` t[0] ``");
        check(t[0:2] == {1,2}.sequence(), "``msg``: tuple[0:2] `` t[0:2] ``");
        check(t[1:2] == {2,3}.sequence(), "``msg``: tuple[1:2] `` t[1:2] ``");
        check(t[2:1] == [3], "``msg``: tuple[2:1] `` t[2:1] ``");
        
        check(t[-1...] == {1,2,3}.sequence(), "``msg``: tuple[-1...] `` t[-1...] ``");
        check(t[0...] == {1,2,3}.sequence(), "``msg``: tuple[0...] `` t[0...] ``");
        check(t[1...] == {2,3}.sequence(), "``msg``: tuple[1...] `` t[1...] ``");
        check(t[2...] == [3], "``msg``: tuple[2...] `` t[2...] ``");
        check(t[3...] == {}, "``msg``: tuple[3...] `` t[3...] ``");
        check(t[...-1] == {}, "``msg``: tuple[...-1] `` t[...-1] ``");
        check(t[...0] == {1}.sequence(), "``msg``: tuple[...0] `` t[...0] ``");
        check(t[...1] == {1, 2}.sequence(), "``msg``: tuple[...1] `` t[...1] ``");
        check(t[...2] == {1, 2, 3}.sequence(), "``msg``: tuple[...2] `` t[...2] ``");
        check(t[...3] == {1, 2, 3}.sequence(), "``msg``: tuple[...3] `` t[...3] ``");
        //Check inherited methods work
        check(1 in t, "``msg``: tuple contains");
        check(t.find((Object x) => x is Integer) exists, "``msg``: tuple find");
        check(t.any((Object x) => x is Integer), "``msg``: tuple any");
        check(t.every((Object x) => true), "``msg``: tuple every");
        check(t.count((Object x) => x is Integer) == 3, "``msg``: tuple count");
    }
    with123([1,2,3], "[1,2,3]");
    with123([1,2,*(3..3)], "[1,2,*(3..3)]");
    
    check(LazyList({123}).hash==[123].hash, "tuple hash");
    
    Sequence<String> strings = ["hello", "bye"];
    [String, Integer, String*] threeTupleEllipsis = ["a", 1, *strings];
    [String*] comprehensionTuple = ["a", "b", for (s in strings) s];

    check(threeTupleEllipsis == {"a", 1, "hello", "bye"}.sequence(), "threeTupleEllipsis");
    check(comprehensionTuple == {"a", "b", "hello", "bye"}.sequence(), "comprehensionTuple");
    check(([for (c in "foo") c.string] of Object) is String[], "comprehension is Sequence");
    check((["foo", "bar"] of Object) is [String+], "is [String+] 1");
    check(!([1, 2] of Object) is [String+], "is [String+] 2");
    check([1,2,3].getFromFirst(100) is Null, "Tuple.getFromFirst");

    //value strs = ["hello", "world"];
    //check(strs.withLeading("yo!").first=="yo!", "tuple withLeading");
    //check(strs.withTrailing("yo!").last=="yo!", "tuple withTrailing");
    //[Integer+] ints = [1,2,3];
    //check(ints.append(5..7)==[1,2,3,5,6,7], "tuple append");
    //check(ints.prepend(5..7)==[5,6,7,1,2,3], "tuple prepend");
    
    // #573, concatenate is used to get a Tuple with a nonempty rest (not optimized to array)
    check(["a", *concatenate(["b"])].append(["c"]) == ["a", "b", "c"], "Tuple.append with sequential rest");
    check(["b", *concatenate(["c"])].withLeading("a") == ["a", "b", "c"], "Tuple.withLeading with sequential rest");
    check(["a", *concatenate(["b"])].withTrailing("c") == ["a", "b", "c"], "Tuple.withTrailing with sequential rest");
    value bug584 = [42, *(1..3)].rest;
    
    check(["x", "y"].initial(1)==["x"], "Tuple.initial");
    check(["x", "y"].initial(3)==["x","y"], "Tuple.initial");
    check(["x", "y"].terminal(1)==["y"], "Tuple.terminal");
    check(["x", "y"].terminal(3)==["x", "y"], "Tuple.terminal");

    // Test Tuple.each
    variable value eachTestCounter = 0;
    [1, 2, *{3, 4}].each((i) => eachTestCounter += i);
    check(eachTestCounter == 10, "Tuple.each with rest");

    eachTestCounter = 0;
    [1, 2, 3, 4].each((i) => eachTestCounter += i);
    check(eachTestCounter == 10, "Tuple.each without rest");

    value tuple = [false, *Singleton(true)];
    
    check(tuple.initial(1)==[false], "tuple.initial");
    check(tuple.terminal(1)==[true], "tuple.terminal");
    
    check(tuple.trim(identity)==[false], "tuple.trim");
    check(tuple.trimLeading(not(identity<Boolean>))==[true], "tuple.trimLeading");
    check(tuple.trimTrailing(identity)==[false], "tuple.trimTrailing");
    
    check(tuple.endsWith([true])==true, "tuple.endsWith");
    check(tuple.startsWith([false, true])==true, "tuple.startsWith");
    
    check(if (exists r=tuple.firstIndexWhere(identity)) then r==1 else false, "tuple.firstIndexWhere");
    check(if (exists r=tuple.lastIndexWhere(identity)) then r==1 else false, "tuple.lastIndexWhere");
    
    check([0, *Singleton(1)].max(uncurry(Integer.compare))==1, "tuple spread 1");
    
    check(tuple.any(identity)==true, "tuple.any");
    check(tuple.every(not(identity<Boolean>))==false, "tuple.every");
    
    check(if (exists r=tuple.find(identity)) then r==true else false, "tuple.find");
    check(if (exists r=tuple.findLast(identity)) then r==true else false, "tuple.findLast");
    
    check(if (exists r=tuple.locate(identity)) then r==1->true else false, "tuple.locate");
    check(if (exists r=tuple.locateLast(identity)) then r==1->true else false, "tuple.locateLast");
    
    try {
        value a = [finished, finished, finished];
        value [b, *c] = a;
        fail("Spread of tuple with initial 'finished' should have thrown");
    } catch (AssertionError e) {
        check(e.message == "length of c is less than minimum length of its static type Finished[2]", "deconstruct [finished] 1");
    }
    
    try {
        value a = [finished, 1, finished];
        value [b, *c] = a;
        fail("Deconstruct of tuple with initial 'finished' should have thrown");
        print(c[1].string);
    } catch (AssertionError e) {
        check(e.message == "length of c is less than minimum length of its static type [Integer, Finished]", "deconstruct [finished] 2");
    }
}
