///
module eerange.base;

@safe:
//~ nothrow:

///
immutable struct EachWithEachOtherRangeBase(T)
{
    @nogc:

    private T srcLength;

    ///
    this(T srcLen) pure
    {
        srcLength = srcLen;
    }

    ///
    size_t length() pure
    {
        const len = srcLength;

        return (len * len - len) / 2;
    }

    private static struct Coords
    {
        T x;
        T y;
    }

    private Coords coordsInSquare(size_t idx) pure
    {
        return Coords(
            cast(T) idx % srcLength,
            cast(T) idx / srcLength
        );
    }

    ///
    T[2] opIndex(size_t idx) pure
    {
        assert(idx < length);

        Coords coords = coordsInSquare(idx);

        import std.traits;
        static assert(isMutable!Coords);

        if(coords.x <= coords.y) // under diagonal line?
        {
            const latestIdx = srcLength - 1;

            // Mirroring coords
            coords.x = latestIdx - coords.x;
            coords.y = latestIdx - coords.y - 1; // shifted above diagonal
        }

        return [coords.x, coords.y];
    }
}

unittest
{
    import std.parallelism;

    enum srcLen = 4;

    auto r = EachWithEachOtherRangeBase!size_t(srcLen);

    size_t cnt;

    foreach(i; 0 .. r.length)
    {
        auto pair = r[i];

        cnt++;
    }

    assert(cnt == 6);
}
