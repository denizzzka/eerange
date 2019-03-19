/// "Each with each other" random range
module eerange.randomrange;

import eerange.base;

@safe:
//~ nothrow:

///
struct EachWithEachOtherRandomAccessRange(T = size_t)
{
    @nogc:

    EachWithEachOtherRangeBase!T base;
    alias base this;

    private size_t fwdIdx;
    private size_t backIdx;

    ///
    this(T srcLen) pure
    {
        base = EachWithEachOtherRangeBase!T(srcLen);

        backIdx = length - 1;
    }

    ///
    bool empty() const @nogc
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
    EachWithEachOtherRandomAccessRange!T save() { return this; }
}

unittest
{
    import std.range.primitives;
    import std.traits;

    alias R = EachWithEachOtherRandomAccessRange!int;

    static assert(hasLength!R);
    static assert(is(typeof(lvalueOf!R[1]) == ElementType!R));
    static assert(isInputRange!R);
    static assert(!isNarrowString!R);
    static assert(is(ReturnType!((R r) => r.save) == R));
    static assert(isForwardRange!R);
    static assert(isBidirectionalRange!R);
    static assert(!is(typeof(lvalueOf!R[$ - 1])));
    static assert(isRandomAccessRange!R);
}

///
auto eweo(T)(T srcLen) pure
{
    return EachWithEachOtherRandomAccessRange!(T)(srcLen);
}

@trusted unittest
{
    import std.parallelism;

    const ubyte testSize = 100;

    auto eeRandom = eweo(testSize);
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
