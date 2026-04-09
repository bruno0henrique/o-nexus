-- Migration: Add loja_id column to tabela_nexus
ALTER TABLE public.tabela_nexus
ADD COLUMN IF NOT EXISTS loja_id text;
