/// "Each with each other" random range
module eerange.randomrange;

import eerange.base;

@safe:

///
struct EachWithEachOtherRandomAccessRange
{
    @nogc:

    EachWithEachOtherRangeBase base;
    //~ alias base this;

    private size_t fwdIdx;
    private size_t backIdx;
    private size_t sliceStart; /// slice index start
    private size_t sliceEnd; ///  slice index end

    ///
    this(size_t srcLen, size_t _sliceStart = 0, size_t _sliceEnd = 0) pure nothrow
    {
        base = EachWithEachOtherRangeBase(srcLen);

        sliceStart = _sliceStart;
        sliceEnd = _sliceEnd ? _sliceEnd : base.length;

        assert(sliceStart < sliceEnd);

        fwdIdx = sliceStart;
        backIdx = sliceEnd;
    }

    ///
    size_t length() pure const nothrow
    {
        return sliceEnd - sliceStart;
    }

    ///
    size_t[2] opIndex(size_t idx) pure
    {
        return base.opIndex(sliceStart + idx);
    }

    ///
    bool empty() const @nogc
    {
        return fwdIdx >= sliceEnd || backIdx < sliceStart;
    }

    auto front() {
        version(D_NoBoundsChecks){}
        else
            assert(!empty); //FIXME

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
    EachWithEachOtherRandomAccessRange save() { return this; }

    ///
    //~ EachWithEachOtherRandomAccessRange opSlice(size_t from, size_t to)
    //~ {
        //~ return EachWithEachOtherRandomAccessRange(base.srcLength, from, to);
    //~ }

    ///
    size_t opDollar(size_t pos)()
    if(pos == 0)
    {
        return length;
    }
}

unittest
{
    import std.range.primitives;
    import std.traits;

    alias R = EachWithEachOtherRandomAccessRange;

    static assert(hasLength!R);
    static assert(is(typeof(lvalueOf!R[1]) == ElementType!R));
    static assert(isInputRange!R);
    static assert(!isNarrowString!R);
    static assert(is(ReturnType!((R r) => r.save) == R));
    static assert(isForwardRange!R);
    static assert(isBidirectionalRange!R);
    //~ static assert(!is(typeof(lvalueOf!R[$ - 1])));
    static assert(isRandomAccessRange!R);
}

///
alias eweo = EachWithEachOtherRandomAccessRange;

@trusted unittest
{
    import std.parallelism;
    import std.format;

    enum ubyte testSize = 100;

    auto eeRandom = eweo(testSize);
    auto randomRes = taskPool.amap!("a[0]", "a[1]")(eeRandom);

    size_t[testSize] cnt;

    foreach(r; randomRes)
    {
        cnt[r[0]]++;
        cnt[r[1]]++;
    }

    foreach(i, r; cnt)
        assert(r == testSize-1, format("%d %d", i, r));
}

unittest
{
    auto eeRandom = eweo(4);

    //~ auto slice = eeRandom[0 .. $];

    //~ assert(slice.length == eeRandom.length);
}
