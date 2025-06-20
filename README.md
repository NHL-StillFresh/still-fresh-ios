# StillFresh

> Keep track of your household consumables effortlessly

StillFresh is an iOS application designed to help users manage and track their household consumables, reducing waste and saving money by keeping track of expiration dates and inventory levels.

## 👥 Team Members
- Gideon Dijkhuis
- Elmedin Arifi
- Jesse van der Voet
- Bram Huiskes

## 🎯 Project Overview

StillFresh is a school project developed by a team of 4 students. The app aims to solve the common problem of keeping track of household items and their expiration dates, helping users reduce waste and manage their inventory more efficiently.

### Key Features
<!-- Update/modify these features based on your final implementation -->
- User authentication and account management
- Inventory tracking system
- Expiration date monitoring
- Push notifications for nearly expired items
- Easy-to-use interface for adding and managing items
- Tips and tricks on recipes

## 🎨 Design

[\[Design information will be added here\]](https://www.figma.com/design/o7c2gT4TtUSy4IpuuzyXfr/Untitled?node-id=0-3321)

## 🔧 Technical Details

### Requirements
- iOS 18.0 or later
- Xcode 16.0 or later

### Technologies Used
- SwiftUI for the user interface
- Supabase for backend services
- [PocketBase Swift](https://github.com/supabase/supabase-swift) for PocketBase integration
- [Dicebear](https://www.dicebear.com/) API (used for profile image generation)

## 🚀 Getting Started

### Installation

### 1. Clone the repository
```bash
git clone git@github.com:NHL-StillFresh/still-fresh-ios.git
```

### 2. Open the project in Xcode
```bash
cd StillFresh
open Still\ Fresh.xcodeproj
```

### 3. Install pocketbase dependencies
- [PocketBase Swift](https://github.com/supabase/supabase-swift)

- When installing the dependency be sure to follow [this guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) (package manager method is not tested nor used)


### 4. Set up Supabase
#### 4.1 Set up the supabase database
- Create a new project in Supabase
- Create a database according to this SQL schema
<details>
<summary>Click to open schema</summary>

```bash
CREATE TABLE public.house_inventories (
  house_inventory_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  house_id uuid NOT NULL,
  product_id uuid NOT NULL,
  inventory_quantity bigint NOT NULL,
  inventory_best_before_date text NOT NULL,
  inventory_purchase_date text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT house_inventories_pkey PRIMARY KEY (house_inventory_id),
  CONSTRAINT house_inventories_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.houses(house_id),
  CONSTRAINT house_inventories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id)
);
CREATE TABLE public.house_membership (
  membership_id uuid NOT NULL DEFAULT gen_random_uuid(),
  house_id uuid NOT NULL DEFAULT auth.uid(),
  user_id uuid DEFAULT auth.uid(),
  CONSTRAINT house_membership_pkey PRIMARY KEY (membership_id),
  CONSTRAINT house_membership_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.houses(house_id),
  CONSTRAINT house_membership_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(user_id)
);
CREATE TABLE public.houses (
  house_address character varying,
  house_name character varying NOT NULL,
  house_image character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  house_id uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT houses_pkey PRIMARY KEY (house_id)
);
CREATE TABLE public.product_receipt_names (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  product_id uuid NOT NULL,
  product_receipt_name text NOT NULL,
  CONSTRAINT product_receipt_names_pkey PRIMARY KEY (id),
  CONSTRAINT product_receipt_names_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id),
  CONSTRAINT product_receipt_names_product_id_fkey1 FOREIGN KEY (product_id) REFERENCES public.products(product_id)
);
CREATE TABLE public.products (
  product_name character varying NOT NULL,
  product_image character varying,
  product_code character varying UNIQUE,
  product_expiration_in_days smallint,
  product_nutritional_value json,
  source_id bigint,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  product_id uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT products_pkey PRIMARY KEY (product_id),
  CONSTRAINT products_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.sources(source_id)
);
CREATE TABLE public.profiles (
  user_id uuid NOT NULL DEFAULT auth.uid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  profile_first_name character varying NOT NULL,
  profile_last_name character varying NOT NULL,
  CONSTRAINT profiles_pkey PRIMARY KEY (user_id)
);
CREATE TABLE public.sources (
  source_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  source_location character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sources_pkey PRIMARY KEY (source_id)
);
```
</details>


#### 4.2 Set up the connection in Still Fresh?
- To set up the Supabase connection head over to ``SupaClient.swift``
- Replace our credentials with your in ``supabaseKey`` and ``supabaseURL`` (Hint: don't want to set up a database? feel free to use our credentials)
- Now the app is ready to be built and/or debugged

### 5. Set up openrouter
- Head over to ``APIKeys.swift``
- Insert your openrouter API key into ``openRouterAPIKey``


## 🤝 Contributing
This is a school project and is primarily maintained by the team members. However, if you'd like to contribute, please:
1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request