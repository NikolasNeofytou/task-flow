# Design Tokens (from Figma Variables Screenshot)

Mapping of the shared Figma color variables to Flutter tokens.

| Figma Name | Value    | Flutter Token       | Intended Use                                  |
|------------|----------|---------------------|-----------------------------------------------|
| Color 1    | #9FFF7F  | `AppColors.success` | Success/accepted states                       |
| Color 2    | #CAE1F0  | `AppColors.surface` | Surfaces/cards, low-emphasis backgrounds      |
| Color 3    | #9747FF  | `AppColors.primary` | Brand primary, main actions                   |
| Color 4    | #FF1E1E  | `AppColors.error`   | Errors/destructive                            |
| Color 5    | #79747E  | `AppColors.neutral` | Neutral text, borders, icons                  |
| Color 6    | #FD32E5  | `AppColors.accent`  | Accent/secondary emphasis (badges/highlights) |
| Color 7    | #FFF239  | `AppColors.warning` | Warnings/caution                              |
| Color 8    | #F97B49  | `AppColors.info`    | Info/tertiary emphasis                        |

## Spacing
`AppSpacing`: xs 4, sm 8, md 12, lg 16, xl 20, xxl 24, xxxl 32.

## Radii
`AppRadii`: sm 8, md 12, lg 16, pill 999.

## Shadows (light theme)
`AppShadows.level1`: blur 8, offset (0,4), black12; `level2`: blur 16, offset (0,8), black26.

## Typography
- Font family: `Inter` (fallback: SF Pro Text, Segoe UI, Roboto, Arial).
- `h1`: 28/34, w700; `h2`: 24/30, w700.
- `titleLarge`: 20/26, w700; `titleMedium`: 18/24, w600.
- `bodyLarge`: 16/24, w500; `bodyMedium`: 14/20, w500.
- `labelLarge`: 14/16, w600; `labelMedium`: 12/16, w600.
