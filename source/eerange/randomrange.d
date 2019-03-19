/// "Each with each other" random range
module eerange.randomrange;

@trusted unittest
{
    import std.range: iota;
    import std.parallelism;

    enum testSize = 100;

    auto eeRandom = iota(0, testSize).eeRandomRange;
    auto randomRes = taskPool.amap!("a[0]", "a[1]")(eeRandom);

    size_t[testSize] cnt;

    foreach(r; randomRes)
    {
        cnt[r[0]]++;
        cnt[r[1]]++;
    }

    foreach(r; cnt)
        assert(r == testSize-1);
}

import eerange.base;

@safe:
@nogc:

///
struct EachWithEachOtherRandomAccessRange(R)
{
    EachWithEachOtherRangeBase!R base;
    alias base this;

    private size_t fwdIdx = 0;
    private size_t backIdx;

    ///
    this(R r)
    {
        base = EachWithEachOtherRangeBase!R(r);

        backIdx = length - 1;
    }

    ///
    bool empty() const
    {
        return fwdIdx >= length || backIdx < 0;
    }

    auto front() {
        version(D_NoBoundsChecks){}
        else
            assert(!empty);

        return opIndex(fwdIdx);
    }

    auto back() {
        version(D_NoBoundsChecks){}
        else
            assert(!empty);

        return opIndex(backIdx);
    }

    ///
    void popFront() { fwdIdx++; }

    ///
    void popBack() { backIdx--; }

    ///
    EachWithEachOtherRandomAccessRange!R save() { return this; }
}

///
auto eeRandomRange(T)(T inputRange) pure @nogc
{
    return EachWithEachOtherRandomAccessRange!(T)(inputRange);
}

unittest
{
    import std.range.primitives;
    import std.traits;

    alias R = EachWithEachOtherRandomAccessRange!(int[]);

    static assert(is(typeof(lvalueOf!R[1]) == ElementType!R));
    static assert(isInputRange!R);
    static assert(is(ReturnType!((R r) => r.save) == R));
    static assert(isForwardRange!R);
    static assert(isBidirectionalRange!R);
    static assert(isRandomAccessRange!R);
}
