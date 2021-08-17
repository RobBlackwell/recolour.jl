#!/usr/bin/env julia

using Pkg
Pkg.activate(normpath(joinpath(@__DIR__, ".")))

using ColorSchemes
using Images
using Colors
using EchogramColorSchemes
using TestImages
using ImageQualityIndexes

zx = ColorScheme([colorant"#000000",
                  colorant"#0000ee",
                  colorant"#ee0000",
                  colorant"#ee00ee",
                  colorant"#00ee00",
                  colorant"#00eeee",
                  colorant"#eeee00",
                  colorant"#eeeeee",
                  colorant"#0000ff",
                  colorant"#ff0000",
                  colorant"#ff00ff",
                  colorant"#00ff00",
                  colorant"#00ffff",
                  colorant"#ffff00",
                  colorant"#ffffff" ],
                 "ZX Spectrum",
                 "The colors used on the Sinclair ZX Spectrum computer.")


spectra = ColorScheme(
    [RGB{N0f8}(r, g, b) for r in [0, 1/3 , 2/3 , 1] for g in [0, 1/3 , 2/3 , 1] for b in [0, 1/3 , 2/3 , 1]],
    "Spectra",
    "The colours used on the Sinclair ZX Spectrum SPECTRA interface.")

function show_colorscheme(cs)
    cs = Lab.(cs)
    cs = sort(cs, by=x->x.l)
    img = Array{RGB{N0f8}}(undef, 10, length(cs) *10)
    for i in 1:length(cs)
        for j in (i-1) * 10 + 1:(i-1) * 10 + 10
            for k in 1:10
                img[k,j] = cs[i]
            end
        end
    end
    return img
end

save("zx.png", show_colorscheme(zx))
save("spectra.png", show_colorscheme(spectra))

"""
    rgb_dist(c1, c2)

Return the squared euclidean distance between two colours, c1 and c2
in RGB space.
"""
function rgb_dist(c1, c2)
    rdiff = float(red(c1)) - float(red(c2))
    gdiff = float(green(c1)) - float(green(c2))
    bdiff = float(blue(c1)) - float(blue(c2))
    return rdiff * rdiff + gdiff * gdiff + bdiff * bdiff
end


"""
    nearest(c, cs, f=colordiff)

Return the nearest colour in colorscheme cs to colour c using the
given colour distance metric f (which defaults to CIEDE2000).
"""
function nearest(c, cs, f=colordiff)
    d = f.(c, cs.colors)
    return cs.colors[argmin(d)]
end


"""
    recolor(img, colorscheme::ColorScheme)

Recolour image using colours from colorscheme, returning the
recoloured image. Use the given colour distance metric f (which
defaults to CIEDE2000).
"""
function recolor(img, colorscheme::ColorScheme, f=colordiff)
    map(x -> nearest(x, colorscheme, f), img)
end

function test(name, img, cs=spectra)
    save("$(name).png", img)
    M1 =  colorfulness(img)

    recoloured =  recolor(img, cs, rgb_dist)
    M2 =  colorfulness(recoloured)
    save("$(name)1.png", recoloured)

    recoloured = recolor(img, cs)
    M3 =  colorfulness(recoloured)
    save("$(name)2.png", recoloured )

    println("Colourfulness $name $M1 $M2 $M3")
end

test("sblair", load("blair.png"))

test("smandril", testimage("mandril_color.tif"))

test("slighthouse", testimage("lighthouse.png"))

test("sbarbara", testimage("barbara_color.png"))

test("schelsea", testimage("chelsea.png"))

test("zxblair", load("blair.png"), zx)

test("zxmandril", testimage("mandril_color.tif"), zx)

test("zxlighthouse", testimage("lighthouse.png"), zx)

test("zxbarbara", testimage("barbara_color.png"), zx)

test("zxchelsea", testimage("chelsea.png"), zx)
