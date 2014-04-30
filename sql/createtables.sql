USE [library]
GO
/****** Object:  Table [dbo].[weeding_bib]    Script Date: 04/29/2014 21:21:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[weeding_bib](
	[bib_ID] [bigint] NOT NULL,
	[librarian_ID] [int] NOT NULL,
	[comment] [varchar](max) NULL,
	[special_collections] [varchar](3) NULL,
	[needs_review] [varchar](3) NULL,
	[special_collections_decision] [varchar](3) NULL,
	[no_weed] [varchar](3) NULL,
	[author] [nvarchar](255) NULL,
	[title] [nvarchar](255) NULL,
	[imprint] [nvarchar](200) NULL,
	[local_note] [varchar](max) NULL,
	[pub_dates_combined] [varchar](9) NULL,
	[date_added] [datetime] NULL,
	[last_updated] [datetime] NULL,
	[last_updated_ID] [int] NULL,
	[complete] [varchar](3) NULL,
	[review_start] [datetime] NULL,
	[printed] [varchar](3) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

USE [library]
GO
/****** Object:  Table [dbo].[weeding_bib_comment]    Script Date: 04/29/2014 21:22:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[weeding_bib_comment](
	[item_barcode] [varchar](50) NULL,
	[faculty_ID] [int] NOT NULL,
	[comment] [varchar](max) NULL,
	[date] [datetime] NULL,
	[suppress] [varchar](50) NULL,
	[bib_ID] [int] NULL,
	[acknowledged] [varchar](3) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

USE [library]
GO
/****** Object:  Table [dbo].[weeding_bib_department]    Script Date: 04/29/2014 21:23:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[weeding_bib_department](
	[bib_ID] [int] NOT NULL,
	[department_ID] [int] NOT NULL
) ON [PRIMARY]

USE [library]
GO
/****** Object:  Table [dbo].[weeding_bib_department]    Script Date: 04/29/2014 21:23:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[weeding_bib_department](
	[bib_ID] [int] NOT NULL,
	[department_ID] [int] NOT NULL
) ON [PRIMARY]

USE [library]
GO
/****** Object:  Table [dbo].[weeding_item]    Script Date: 04/29/2014 21:24:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[weeding_item](
	[item_barcode] [varchar](50) NOT NULL,
	[librarian_ID] [int] NOT NULL,
	[comment] [varchar](max) NULL,
	[date_added] [datetime] NOT NULL,
	[special_collections] [varchar](50) NULL,
	[needs_review] [varchar](50) NULL,
	[last_updated] [datetime] NULL,
	[special_collections_decision] [varchar](50) NULL,
	[no_weed] [varchar](50) NULL,
	[bib_ID] [bigint] NULL,
	[display_call_no] [varchar](50) NULL,
	[normalized_call_no] [varchar](50) NULL,
	[location_code] [varchar](50) NULL,
	[item_enum] [varchar](50) NULL,
	[chron] [varchar](50) NULL,
	[item_year] [varchar](50) NULL,
	[copy_number] [int] NULL,
	[complete] [varchar](3) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

