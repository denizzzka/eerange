/// "Each with each other" random range
module eerange.randomrange;

import eerange.base;

@safe:

///
struct EachWithEachOtherRandomAccessRange
{
    @nogc:

    EachWithEachOtherRangeBase base;

    private size_t fwdIdx;
    private ptrdiff_t backIdx;
    private size_t sliceStart; /// slice index start
    private size_t sliceEnd; ///  slice index end

    ///
    this(size_t srcLen, size_t _sliceStart = 0, size_t _sliceEnd = 0) pure nothrow
    {
        base = EachWithEachOtherRangeBase(srcLen);

        sliceStart = _sliceStart;
        sliceEnd = _sliceEnd ? _sliceEnd : base.length;

        assert(sliceStart <= sliceEnd);
        //~ import std.conv: to;
        //~ assert(sliceStart <= sliceEnd, "srcLen="~srcLen.to!string~" sliceStart="~sliceStart.to!string~" sliceEnd="~sliceEnd.to!string);

        fwdIdx = sliceStart;
        backIdx = sliceEnd - 1;
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

    private void checkEmpty()
    {
        version(D_NoBoundsChecks){}
        else
        {
            import core.exception: RangeError;

            if(empty)
                throw new RangeError;
        }
    }

    auto front() {
        checkEmpty();

        return base.opIndex(fwdIdx);
    }

    auto back() {
        checkEmpty();

        return base.opIndex(backIdx);
    }

    ///
    void popFront() { fwdIdx++; }

    ///
    void popBack() { backIdx--; }

    ///
    EachWithEachOtherRandomAccessRange save() { return this; }

    ///
    EachWithEachOtherRandomAccessRange opSlice(size_t from, size_t to)
    {
        return EachWithEachOtherRandomAccessRange(base.srcLength, sliceStart + from, sliceStart + to);
    }

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
    auto slice1 = eeRandom[0 .. 50];
    auto slice2 = eeRandom[50 .. $];

    auto randomRes1 = taskPool.amap!("a[0]", "a[1]")(slice1);
    auto randomRes2 = taskPool.amap!("a[0]", "a[1]")(slice2);

    size_t[testSize] cnt;

    foreach(r; randomRes1)
    {
        cnt[r[0]]++;
        cnt[r[1]]++;
    }

    foreach(r; randomRes2)
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

    auto slice = eeRandom[0 .. $];

    assert(slice.length == eeRandom.length);
}

unittest
{
    auto zero = eweo(0);

    assert(zero.empty);

    auto single = eweo(1);

    assert(single.empty);
}
