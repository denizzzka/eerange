///
module eerange.base;

@safe:

///
struct EachWithEachOtherRangeBase
{
    @nogc:

    package size_t srcLength;

    ///
    this(size_t srcLen) pure nothrow
    {
        srcLength = srcLen;
    }

    ///
    size_t length() pure const nothrow
    {
        const len = srcLength;

        return (len * len - len) / 2;
    }

    private static struct Coords
    {
        size_t x;
        size_t y;
    }

    private Coords coordsInSquare(size_t idx) pure
    {
        return Coords(
            idx % srcLength,
            idx / srcLength
        );
    }

    ///
    size_t[2] opIndex(size_t idx) pure
    {
        version(D_NoBoundsChecks){}
        else
        {
            import core.exception: RangeError;

            if(idx >= length)
                throw new RangeError;
        }

        Coords coords = coordsInSquare(idx);

        import std.traits;
        static assert(isMutable!(typeof(coords)));

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

    auto r = EachWithEachOtherRangeBase(srcLen);

    size_t cnt;

    foreach(i; 0 .. r.length)
    {
        auto pair = r[i];

        cnt++;
    }

    assert(cnt == 6);
}
