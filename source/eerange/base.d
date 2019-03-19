///
module eerange.base;

unittest
{
    import std.parallelism;

    int[] arr = [100, 200, 300, 400];

    auto r = EachWithEachOtherRangeBase!(int[])(arr);

    size_t cnt;

    foreach(i; 0 .. r.length)
    {
        auto pair = r[i];

        cnt++;
    }

    assert(cnt == 6);
}

@safe:
@nogc:

///
struct EachWithEachOtherRangeBase(R)
{
    private R srcRange;

    ///
    this(R r)
    {
        srcRange = r;
    }

    ///
    size_t length() const pure
    {
        const len = srcRange.length;

        return (len * len - len) / 2;
    }

    private static struct Coords
    {
        size_t x;
        size_t y;
    }

    private Coords coordsInSquare(size_t idx) const pure
    {
        return Coords(
            idx % srcRange.length,
            idx / srcRange.length
        );
    }

    import std.range.primitives: ElementType;

    private alias T = ElementType!R;

    private T[2] getElemBySquareCoords(Coords c) const pure
    {
        return [srcRange[c.x], srcRange[c.y]];
    }

    ///
    T[2] opIndex(size_t idx) const pure
    {
        assert(idx < length);

        Coords coords = coordsInSquare(idx);

        if(coords.x <= coords.y) // under diagonal line?
        {
            const latestIdx = srcRange.length - 1;

            // Mirroring coords
            coords.x = latestIdx - coords.x;
            coords.y = latestIdx - coords.y - 1; // shifted above diagonal
        }

        return getElemBySquareCoords(coords);
    }
}
