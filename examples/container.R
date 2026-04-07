library(shiny)
library(shinyGizmo)

# -- Reusable card helper ------------------------------------------------------
card <- function(..., title = NULL, bg = "#fff") {
  div(
    style = htmltools::css(
      background = bg,
      padding = "16px",
      `border-radius` = "8px",
      `box-shadow` = "0 1px 3px rgba(0,0,0,.12)"
    ),
    if (!is.null(title)) h4(title, style = "margin-top:0;"),
    ...
  )
}

ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background: #f0f2f5; font-family: system-ui, sans-serif; }
    h3 { border-bottom: 2px solid #4a90d9; padding-bottom: 6px; }
  "))),

  h2("CSS Container Query + Grid examples"),

  # --------------------------------------------------------------------------
  # Example 1: Basic responsive grid with template_areas
  # --------------------------------------------------------------------------
  h3("1. Dashboard layout (resize browser to see reflow)"),
  p("Wide: sidebar + main side-by-side. Narrow (<700px): stacked."),

  container(
    name = "dashboard",
    card(title = "Sidebar",
      p("Navigation, filters, etc."),
      tags$ul(
        tags$li("Link A"),
        tags$li("Link B"),
        tags$li("Link C")
      )
    ) %>% grid_item(area = "sidebar"),

    card(title = "Main content",
      p("This is the primary content area."),
      p("It takes up more space when the container is wide enough.")
    ) %>% grid_item(area = "main"),

    conditions = list(
      # Default: two-column layout
      condition(
        !!!grid(
          template_areas = list(c("sidebar", "main")),
          template_columns = "250px 1fr",
          gap = "16px"
        )
      ),
      # Narrow: stack vertically
      condition(
        query = "width < 700px",
        !!!grid(
          template_areas = list(c("sidebar"), c("main")),
          gap = "12px"
        )
      )
    )
  ),

  br(),

  # --------------------------------------------------------------------------
  # Example 2: Card grid with auto-fill
  # --------------------------------------------------------------------------
  h3("2. Auto-fill card grid"),
  p("Cards automatically wrap based on container width."),

  container(
    name = "card_grid",
    card(title = "Analytics",  bg = "#e8f4fd", p("Chart goes here")),
    card(title = "Revenue",    bg = "#e8fde8", p("$12,345")),
    card(title = "Users",      bg = "#fde8e8", p("1,234 active")),
    card(title = "Performance", bg = "#fdf4e8", p("99.9% uptime")),
    card(title = "Storage",    bg = "#f4e8fd", p("42 GB used")),
    card(title = "Alerts",     bg = "#fde8f4", p("3 pending")),
    conditions = list(
      condition(
        !!!grid(
          auto_fill = TRUE,
          auto_columns = "minmax(200px, 1fr)",
          gap = "16px"
        )
      )
    )
  ),

  br(),

  # --------------------------------------------------------------------------
  # Example 3: Conditions with .extra_css for child styling
  # --------------------------------------------------------------------------
  h3("3. Container queries with child styling"),
  p("Background, font size, and child element styles change at breakpoints."),

  container(
    name = "styled_panel",
    div(class = "header", "Header area"),
    div(class = "body", "Body content area"),
    div(class = "footer", "Footer"),
    conditions = list(
      # Base styles
      condition(
        !!!grid(
          template_areas = list(c("header"), c("body"), c("footer")),
          gap = "8px"
        ),
        .extra_css = list(
          ".header" = htmltools::css(
            padding = "12px",
            background = "#4a90d9",
            color = "white",
            `font-weight` = "bold",
            `border-radius` = "6px 6px 0 0"
          ),
          ".body" = htmltools::css(
            padding = "16px",
            background = "white",
            `min-height` = "80px"
          ),
          ".footer" = htmltools::css(
            padding = "8px 12px",
            background = "#f5f5f5",
            `font-size` = "12px",
            `border-radius` = "0 0 6px 6px"
          )
        )
      ),
      # Wide: switch to header spanning two columns
      condition(
        query = "width > 800px",
        !!!grid(
          template_areas = list(
            c("header", "header"),
            c("body",   "footer")
          ),
          template_columns = "1fr 300px",
          gap = "0"
        ),
        .extra_css = list(
          ".header" = htmltools::css(
            `font-size` = "20px",
            background = "#0d4717ff",
            `border-radius` = "6px 6px 0 0"
          ),
          ".body" = htmltools::css(`min-height` = "120px"),
          ".footer" = htmltools::css(
            `border-radius` = "0 0 6px 0",
            `border-left` = "1px solid #ddd"
          )
        )
      )
    )
  ),

  br(),

  # --------------------------------------------------------------------------
  # Example 4: Nested containers
  # --------------------------------------------------------------------------
  h3("4. Nested containers"),
  p("Outer container controls the overall layout; inner container adapts independently."),

  container(
    name = "outer",
    card(title = "Left panel", p("Static content")) %>% grid_item(area = "left"),

    container(
      name = "inner",
      card(title = "Card A", bg = "#ffe0b2", p("Nested card A")) %>% grid_item(area = "a"),
      card(title = "Card B", bg = "#c8e6c9", p("Nested card B")) %>% grid_item(area = "b"),
      card(title = "Card C", bg = "#bbdefb", p("Nested card C")) %>% grid_item(area = "c"),
      conditions = list(
        condition(
          !!!grid(
            template_areas = list(c("a", "b", "c")),
            gap = "12px"
          )
        ),
        condition(
          query = "width < 500px",
          !!!grid(
            template_areas = list(c("a"), c("b"), c("c")),
            gap = "8px"
          )
        )
      )
    ) %>% grid_item(area = "right"),

    conditions = list(
      condition(
        !!!grid(
          template_areas = list(c("left", "right")),
          template_columns = "300px 1fr",
          gap = "16px"
        )
      ),
      condition(
        query = "width < 700px",
        !!!grid(
          template_areas = list(c("left"), c("right")),
          gap = "12px"
        )
      )
    )
  ),

  br(),

  # --------------------------------------------------------------------------
  # Example 5: Grid item placement with row/column spans
  # --------------------------------------------------------------------------
  h3("5. Explicit grid placement with row/column spans"),
  p("Using row_start/row_end and column_start/column_end for precise control."),

  container(
    name = "explicit_grid",
    card(title = "Wide banner", bg = "#e1bee7",
      p("Spans all 3 columns")
    ) %>% grid_item(column_start = 1, column_end = 4, row_start = 1),

    card(title = "Tall side", bg = "#b2dfdb",
      p("Spans 2 rows")
    ) %>% grid_item(column_start = 1, row_start = 2, row_end = 4),

    card(title = "Cell 1", bg = "#fff9c4",
      p("Regular cell")
    ) %>% grid_item(column_start = 2, row_start = 2),

    card(title = "Cell 2", bg = "#ffccbc",
      p("Regular cell")
    ) %>% grid_item(column_start = 3, row_start = 2),

    card(title = "Bottom wide", bg = "#d1c4e9",
      p("Spans columns 2-3")
    ) %>% grid_item(column_start = 2, column_end = 4, row_start = 3),

    conditions = list(
      condition(
        !!!grid(
          template_columns = "1fr 1fr 1fr",
          template_rows = "auto 1fr 1fr",
          gap = "12px"
        )
      )
    )
  ),

  br()
)

server <- function(input, output, session) {}

shinyApp(ui, server)
