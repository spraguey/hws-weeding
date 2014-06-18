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

GO

USE [library]
GO
/****** Object:  Table [dbo].[department]    Script Date: 6/17/2014 10:02:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[department](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NULL,
	[see] [int] NULL,
	[suppress_approval] [varchar](50) NULL,
 CONSTRAINT [PK_department] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [library]
GO
/****** Object:  Table [dbo].[requestor_department]    Script Date: 6/17/2014 10:02:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[requestor_department](
	[requestor_ID] [int] NOT NULL,
	[department_ID] [int] NULL
) ON [PRIMARY]

GO


USE [library]
GO

USE [library]
GO

/****** Object:  Table [dbo].[user]    Script Date: 6/17/2014 10:03:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[user](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[firstname] [varchar](50) NULL,
	[lastname] [varchar](50) NULL,
	[alias] [varchar](50) NULL,
	[role] [varchar](50) NULL,
	[image_url] [varchar](max) NULL,
	[email] [varchar](50) NULL,
	[phone] [varchar](50) NULL,
	[department] [varchar](50) NULL,
	[title] [varchar](100) NULL,
	[directory_order] [int] NULL,
	[url] [varchar](50) NULL,
	[cwid] [varchar](50) NULL,
	[nomail] [varchar](50) NULL,
	[expired] [varchar](50) NULL,
	[last_updated] [datetime] NULL,
	[library_department_ID] [int] NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [library]
GO

/****** Object:  Table [dbo].[user_permission]    Script Date: 6/17/2014 10:04:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[user_permission](
	[user_ID] [int] NOT NULL,
	[permission_ID] [int] NOT NULL
) ON [PRIMARY]

GO


USE [library]
GO

/****** Object:  Table [dbo].[library_department]    Script Date: 6/17/2014 10:19:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[library_department](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[phone] [varchar](50) NULL,
	[fax] [varchar](50) NULL,
	[url] [varchar](50) NULL,
 CONSTRAINT [PK_library_department] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [library]
GO

/****** Object:  Table [dbo].[permission]    Script Date: 6/17/2014 10:22:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[permission](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](50) NULL,
 CONSTRAINT [PK_permission] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


INSERT INTO [dbo].[permission]
    ([description])
SELECT 'Liaison' UNION ALL SELECT 'Cataloging' UNION ALL SELECT 'Archives'
GO
