-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 24, 2026 at 01:26 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_absensi_candratama`
--

-- --------------------------------------------------------

--
-- Table structure for table `app_notifications`
--

CREATE TABLE `app_notifications` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_notifications`
--

INSERT INTO `app_notifications` (`id`, `user_id`, `title`, `body`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 2, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:35', '2026-07-03 00:29:35'),
(2, 3, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 1, '2026-07-03 00:29:35', '2026-07-03 01:07:11'),
(3, 4, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 1, '2026-07-03 00:29:35', '2026-07-03 02:02:58'),
(4, 5, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 1, '2026-07-03 00:29:35', '2026-07-03 01:07:56'),
(5, 6, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 1, '2026-07-03 00:29:35', '2026-07-03 00:30:51'),
(6, 7, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:39', '2026-07-03 00:29:39'),
(7, 8, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:39', '2026-07-03 00:29:39'),
(8, 9, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:39', '2026-07-03 00:29:39'),
(9, 10, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:39', '2026-07-03 00:29:39'),
(10, 11, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:39', '2026-07-03 00:29:39'),
(11, 12, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-03 00:29:39', '2026-07-03 00:29:39'),
(12, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:18', '2026-07-03 00:31:18'),
(13, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 1, '2026-07-03 00:31:18', '2026-07-03 01:07:11'),
(14, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 1, '2026-07-03 00:31:18', '2026-07-03 02:02:58'),
(15, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 1, '2026-07-03 00:31:18', '2026-07-03 01:07:56'),
(16, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 1, '2026-07-03 00:31:18', '2026-07-03 00:33:53'),
(17, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:19', '2026-07-03 00:31:19'),
(18, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:19', '2026-07-03 00:31:19'),
(19, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:20', '2026-07-03 00:31:20'),
(20, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:20', '2026-07-03 00:31:20'),
(21, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:20', '2026-07-03 00:31:20'),
(22, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:00 WIB.', 0, '2026-07-03 00:31:20', '2026-07-03 00:31:20'),
(23, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:34:59', '2026-07-03 00:34:59'),
(24, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 1, '2026-07-03 00:34:59', '2026-07-03 01:07:11'),
(25, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 1, '2026-07-03 00:34:59', '2026-07-03 02:02:58'),
(26, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 1, '2026-07-03 00:34:59', '2026-07-03 01:07:56'),
(27, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 1, '2026-07-03 00:34:59', '2026-07-07 01:44:15'),
(28, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:35:00', '2026-07-03 00:35:00'),
(29, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:35:00', '2026-07-03 00:35:00'),
(30, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:35:00', '2026-07-03 00:35:00'),
(31, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:35:00', '2026-07-03 00:35:00'),
(32, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:35:00', '2026-07-03 00:35:00'),
(33, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 07:35 WIB.', 0, '2026-07-03 00:35:00', '2026-07-03 00:35:00'),
(34, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:19', '2026-07-03 00:52:19'),
(35, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 1, '2026-07-03 00:52:19', '2026-07-03 01:07:11'),
(36, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 1, '2026-07-03 00:52:20', '2026-07-03 02:02:58'),
(37, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 1, '2026-07-03 00:52:20', '2026-07-03 01:07:56'),
(38, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 1, '2026-07-03 00:52:20', '2026-07-07 01:44:15'),
(39, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:20', '2026-07-03 00:52:20'),
(40, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:20', '2026-07-03 00:52:20'),
(41, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:20', '2026-07-03 00:52:20'),
(42, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:20', '2026-07-03 00:52:20'),
(43, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:20', '2026-07-03 00:52:20'),
(44, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 00:52:20', '2026-07-03 00:52:20'),
(45, 12, 'Izin Ditolak!', 'Pengajuan izin Anda ditolak. Alasan Admin: Foto tidak meyakinkan', 0, '2026-07-03 01:04:33', '2026-07-03 01:04:33'),
(46, 5, 'Izin Disetujui!', 'Pengajuan izin/sakit Anda untuk tanggal 03 Jul 2026 telah disetujui oleh Admin.', 1, '2026-07-03 01:05:10', '2026-07-03 01:07:56'),
(47, 3, 'Izin Ditolak!', 'Pengajuan izin Anda ditolak. Alasan Admin: Dokumen tidak terlihat jelas', 1, '2026-07-03 01:06:48', '2026-07-03 01:07:11'),
(48, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:13', '2026-07-03 01:27:13'),
(49, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:13', '2026-07-03 01:27:13'),
(50, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 1, '2026-07-03 01:27:13', '2026-07-03 02:02:58'),
(51, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(52, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 1, '2026-07-03 01:27:14', '2026-07-07 01:44:15'),
(53, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(54, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(55, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(56, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(57, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(58, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:20 WIB.', 0, '2026-07-03 01:27:14', '2026-07-03 01:27:14'),
(59, 4, 'Pengumuman Libur', 'Kantor akan diliburkan pada 07 Juli 2026. Keterangan: Kantor di Renovasi', 1, '2026-07-03 02:02:18', '2026-07-03 02:02:58'),
(60, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(61, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(62, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 1, '2026-07-03 02:05:03', '2026-07-07 01:53:24'),
(63, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(64, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 1, '2026-07-03 02:05:03', '2026-07-07 01:44:15'),
(65, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(66, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(67, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(68, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(69, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(70, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(71, 14, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-03 02:05:03', '2026-07-03 02:05:03'),
(72, 2, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:49', '2026-07-07 01:43:49'),
(73, 3, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:49', '2026-07-07 01:43:49'),
(74, 4, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 1, '2026-07-07 01:43:49', '2026-07-07 01:53:24'),
(75, 5, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:49', '2026-07-07 01:43:49'),
(76, 6, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 1, '2026-07-07 01:43:49', '2026-07-07 01:44:15'),
(77, 7, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(78, 8, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(79, 9, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(80, 10, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(81, 11, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(82, 12, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(83, 14, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-07 01:43:52', '2026-07-07 01:43:52'),
(84, 4, 'Izin Ditolak!', 'Pengajuan izin Anda ditolak. Alasan Admin: Kurang jelas', 1, '2026-07-07 01:53:03', '2026-07-07 01:53:24'),
(85, 4, 'Izin Disetujui!', 'Pengajuan izin/sakit Anda untuk tanggal 07 Jul 2026 telah disetujui oleh Admin.', 1, '2026-07-07 01:55:46', '2026-07-07 01:56:11'),
(86, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:04', '2026-07-07 02:01:04'),
(87, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:04', '2026-07-07 02:01:04'),
(88, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:04', '2026-07-07 02:01:04'),
(89, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:04', '2026-07-07 02:01:04'),
(90, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:04', '2026-07-07 02:01:04'),
(91, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(92, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(93, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(94, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(95, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(96, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(97, 14, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 08:30 WIB.', 0, '2026-07-07 02:01:05', '2026-07-07 02:01:05'),
(98, 6, 'Pengumuman Libur', 'Kantor akan diliburkan pada 08 Juli 2026. Keterangan: Cuti libur hari raya', 0, '2026-07-07 02:10:41', '2026-07-07 02:10:41'),
(99, 2, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:01', '2026-07-14 13:16:01'),
(100, 3, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:01', '2026-07-14 13:16:01'),
(101, 4, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:01', '2026-07-14 13:16:01'),
(102, 5, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:01', '2026-07-14 13:16:01'),
(103, 6, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:01', '2026-07-14 13:16:01'),
(104, 7, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(105, 8, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(106, 9, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(107, 10, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(108, 11, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(109, 12, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(110, 14, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(111, 17, 'Perubahan Jam Pulang Kerja', 'Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul 16:30 WIB.', 0, '2026-07-14 13:16:04', '2026-07-14 13:16:04'),
(112, 2, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:30', '2026-07-21 06:09:30'),
(113, 3, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:30', '2026-07-21 06:09:30'),
(114, 4, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:30', '2026-07-21 06:09:30'),
(115, 5, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:30', '2026-07-21 06:09:30'),
(116, 6, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:30', '2026-07-21 06:09:30'),
(117, 7, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(118, 8, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(119, 9, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(120, 10, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(121, 11, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(122, 12, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(123, 14, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(124, 17, 'Perubahan Lokasi Kantor', 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.', 0, '2026-07-21 06:09:34', '2026-07-21 06:09:34'),
(125, 6, 'Lembur Disetujui!', 'Pengajuan lembur Anda untuk tanggal 21 Jul 2026 telah disetujui oleh Admin.', 0, '2026-07-21 07:44:45', '2026-07-21 07:44:45'),
(126, 4, 'Lembur Disetujui!', 'Pengajuan lembur Anda untuk tanggal 23 Jul 2026 telah disetujui oleh Admin.', 0, '2026-07-23 02:50:45', '2026-07-23 02:50:45');

-- --------------------------------------------------------

--
-- Table structure for table `attendances`
--

CREATE TABLE `attendances` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `time_in` time DEFAULT NULL,
  `time_out` time DEFAULT NULL,
  `lat_in` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `long_in` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lat_out` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `long_out` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo_in` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo_out` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('hadir','terlambat','izin','sakit','alpha') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'hadir',
  `late_reason` text COLLATE utf8mb4_unicode_ci,
  `late_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_auto_checkout` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `attendances`
--

INSERT INTO `attendances` (`id`, `user_id`, `date`, `time_in`, `time_out`, `lat_in`, `long_in`, `lat_out`, `long_out`, `photo_in`, `photo_out`, `status`, `late_reason`, `late_photo`, `is_auto_checkout`, `notes`, `created_at`, `updated_at`) VALUES
(1, 6, '2026-07-03', '07:24:00', '16:36:21', '-7.8290508', '112.0170546', '-7.8290495', '112.0170623', 'attendances/NZveiuOndYlx8AJW493usIgg7lJWsS6TEy7QrWCn.jpg', 'attendances/oEoRPy9j9EqVgjhTmNjVkmnlmoy5jGaAFKTzkvzX.jpg', 'hadir', '', NULL, 0, NULL, '2026-07-03 00:30:33', '2026-07-03 00:36:26'),
(2, 2, '2026-07-03', '07:21:48', '16:42:12', '-7.8290508', '112.0170546', '-7.8290495', '112.0170623', 'attendances/NZveiuOndYlx8AJW493usIgg7lJWsS6TEy7QrWCn.jpg', 'attendances/oEoRPy9j9EqVgjhTmNjVkmnlmoy5jGaAFKTzkvzX.jpg', 'hadir', NULL, NULL, 0, NULL, '2026-07-03 00:30:33', '2026-07-03 00:36:26'),
(3, 4, '2026-07-02', '07:29:40', '17:30:14', '-7.8290508', '112.0170546', '-7.8290495', '112.0170546', 'attendances/NZveiuOndYlx8AJW493usIgg7lJWsS6TEy7QrWCn.jpg', 'attendances/NZveiuOndYlx8AJW493usIgg7lJWsS6TEy7QrWCn.jpg', 'hadir', NULL, NULL, 0, NULL, '2026-07-03 00:30:33', '2026-07-03 00:36:26'),
(4, 4, '2026-07-03', '08:14:22', '16:33:14', '-7.8290294', '112.0170505', '-7.8290294', '112.0170505', 'attendances/zCqaQGzFWZ6rUxGL0IQzEe8lSBRe1Z0N0nc2V8JS.jpg', 'attendances/zCqaQGzFWZ6rUxGL0IQzEe8lSBRe1Z0N0nc2V8JS.jpg', 'terlambat', 'Terjebak macet kereta lewat', 'attendances/late/cD0gvgWzdiVQdYeB6Y8YGn4rSheDk9zt2HkSnNz9.jpg', 0, NULL, '2026-07-03 01:14:22', '2026-07-03 01:14:22'),
(5, 4, '2026-07-01', '07:15:02', '16:43:00', '-7.8290294', '112.0170505', '-7.8290294', '112.0170505', 'attendances/zCqaQGzFWZ6rUxGL0IQzEe8lSBRe1Z0N0nc2V8JS.jpg', 'attendances/zCqaQGzFWZ6rUxGL0IQzEe8lSBRe1Z0N0nc2V8JS.jpg', 'hadir', NULL, NULL, 0, NULL, NULL, NULL),
(6, 6, '2026-07-07', '08:45:59', '16:43:00', '-7.8027775', '111.9796846', '-7.8027775', '111.9796846', 'attendances/uL2hr3Gku7SHzm0ZYjiNYVTcVUSxpinxLefWb4kh.jpg', 'attendances/uL2hr3Gku7SHzm0ZYjiNYVTcVUSxpinxLefWb4kh.jpg', 'terlambat', 'Macet di jalan', 'attendances/late/dcddkqmelixMX2YsaJdUIuyK3WP6teUdqOuooPyM.jpg', 0, NULL, '2026-07-07 01:46:00', '2026-07-07 01:46:00'),
(7, 6, '2026-07-21', '13:12:55', '16:43:00', '-7.8020653', '111.9798891', '-7.8020653', '111.9798891', 'attendances/iVfh0HNXFzJVDii7K5ZFvc3inNViSUmJg2nrTeoi.jpg', 'attendances/iVfh0HNXFzJVDii7K5ZFvc3inNViSUmJg2nrTe...', 'terlambat', 'macet terjebak kereta', 'attendances/late/VwboTqJKFhQ1MIUqNmj7VNFAVjfJioj9D41bmx5l.jpg', 0, NULL, '2026-07-21 06:12:55', '2026-07-21 06:12:55'),
(8, 6, '2026-07-22', '07:12:42', '16:43:00', '-7.8020653', '111.9798891', '-7.8020653', '111.9798891', 'attendances/uL2hr3Gku7SHzm0ZYjiNYVTcVUSxpinxLefWb4kh.jpg', 'attendances/iVfh0HNXFzJVDii7K5ZFvc3inNViSUmJg2nrTe...', 'hadir', NULL, NULL, 0, NULL, NULL, NULL),
(9, 6, '2026-07-23', '07:26:20', '16:50:00', '-7.8020653', '111.9798891', '7.8020653', '111.9798891', 'attendances/NZveiuOndYlx8AJW493usIgg7lJWsS6TEy7QrWCn.jpg', 'attendances/NZveiuOndYlx8AJW493usIgg7lJWsS6TEy7QrW...', 'hadir', NULL, NULL, 0, NULL, NULL, NULL),
(10, 4, '2026-07-23', '09:49:32', NULL, '-7.8027164', '111.979829', NULL, NULL, 'attendances/Yd7qGldy7C6LgpxJb7k5SdmwokwNYWzAnwQGMYVi.jpg', NULL, 'terlambat', 'menunggu bis di terminal', 'attendances/late/05Oyrc65U1CPksWirahw8pXyoiVV1tXV27HITfAR.jpg', 0, NULL, '2026-07-23 02:49:32', '2026-07-23 02:49:32');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('laravel-cache-356a192b7913b04c54574d18c28d46e6395428ab', 'i:1;', 1783045086),
('laravel-cache-356a192b7913b04c54574d18c28d46e6395428ab:timer', 'i:1783045086;', 1783045086),
('laravel-cache-google_holidays_2026', 'a:0:{}', 1784121551),
('laravel-cache-holidays_month_2026_7', 'a:0:{}', 1784121406),
('laravel-cache-kalender_libur_terbaru_2026', 'a:0:{}', 1784860750),
('laravel-cache-livewire-rate-limiter:16d36dff9abd246c67dfac3e63b993a169af77e6', 'i:1;', 1784034962),
('laravel-cache-livewire-rate-limiter:16d36dff9abd246c67dfac3e63b993a169af77e6:timer', 'i:1784034962;', 1784034962),
('laravel-cache-livewire-rate-limiter:3a613ac5623e80d407ec2270a9a87484a58d77c7', 'i:1;', 1783037799),
('laravel-cache-livewire-rate-limiter:3a613ac5623e80d407ec2270a9a87484a58d77c7:timer', 'i:1783037799;', 1783037799),
('laravel-cache-livewire-rate-limiter:732e22945a3a815d268cdde23518cff958621d24', 'i:1;', 1784613295),
('laravel-cache-livewire-rate-limiter:732e22945a3a815d268cdde23518cff958621d24:timer', 'i:1784613295;', 1784613295),
('laravel-cache-livewire-rate-limiter:8c260f2eccd1ba7e968b77f2b46c110ff6e2714e', 'i:1;', 1784774401),
('laravel-cache-livewire-rate-limiter:8c260f2eccd1ba7e968b77f2b46c110ff6e2714e:timer', 'i:1784774401;', 1784774401),
('laravel-cache-livewire-rate-limiter:9153c0c051754f8bb4d978643785ed1990d6ae29', 'i:1;', 1783388604),
('laravel-cache-livewire-rate-limiter:9153c0c051754f8bb4d978643785ed1990d6ae29:timer', 'i:1783388604;', 1783388604);

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_holidays`
--

CREATE TABLE `company_holidays` (
  `id` bigint UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `company_holidays`
--

INSERT INTO `company_holidays` (`id`, `start_date`, `end_date`, `description`, `created_at`, `updated_at`) VALUES
(2, '2026-07-08', '2026-07-08', 'Cuti libur hari raya', '2026-07-07 02:10:41', '2026-07-07 02:10:41');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leaves`
--

CREATE TABLE `leaves` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `attachment` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reject_reason` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `leaves`
--

INSERT INTO `leaves` (`id`, `user_id`, `type`, `start_date`, `end_date`, `reason`, `attachment`, `status`, `reject_reason`, `created_at`, `updated_at`) VALUES
(1, 3, 'Sakit', '2026-07-03', '2026-07-03', 'Izin tidak masuk karena sakit', 'leaves/QdJUsS8hPPnfFwgcNa0dXmKfPw2t7SRAyYR8OFmr.jpg', 'rejected', 'Dokumen tidak terlihat jelas', '2026-07-03 00:55:02', '2026-07-03 01:06:48'),
(2, 12, 'Izin', '2026-07-03', '2026-07-03', 'Izin tidak masuk masih di rumah sakit', 'leaves/z6CR9xUi42LlYeE9GmlZ3vxXo4ioQuZtudQGRUsB.jpg', 'rejected', 'Foto tidak meyakinkan', '2026-07-03 00:59:12', '2026-07-03 01:04:33'),
(3, 5, 'Sakit', '2026-07-03', '2026-07-03', 'izin tidak masuk dikarenakan demam', 'leaves/JcbDXeJrjYQCXTwvRLU6bFLoa0qBV9PjbE4MpMNy.jpg', 'approved', NULL, '2026-07-03 01:01:45', '2026-07-03 01:05:10'),
(4, 4, 'Sakit', '2026-07-07', '2026-07-07', 'Sakit demam', 'leaves/eIZNgHxnFSFHCxex2fXJNHHPqbY9TCdjlioeHWXw.jpg', 'rejected', 'Kurang jelas', '2026-07-07 01:49:44', '2026-07-07 01:53:03'),
(5, 4, 'Sakit', '2026-07-07', '2026-07-07', 'Sakit demam', 'leaves/XsKhOEqI4FFrnQ7B8KDUIKKLGocaWHYgz7FloBE2.jpg', 'approved', NULL, '2026-07-07 01:55:30', '2026-07-07 01:55:46');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_02_23_035427_create_attendances_table', 1),
(5, '2026_02_23_035510_create_settings_table', 1),
(6, '2026_02_23_040525_create_personal_access_tokens_table', 1),
(7, '2026_02_24_142901_add_photo_to_users_table', 1),
(8, '2026_02_24_155449_add_nip_to_users_table', 1),
(9, '2026_02_25_092232_create_leaves_table', 1),
(10, '2026_02_27_132300_make_attendances_columns_nullable', 1),
(11, '2026_02_27_150903_create_app_notifications_table', 1),
(12, '2026_02_28_104714_create_notifications_table', 1),
(13, '2026_03_17_085535_add_device_id_to_users_table', 1),
(14, '2026_03_28_095832_add_start_time_to_settings_table', 1),
(15, '2026_03_28_152114_add_late_reason_to_attendances_table', 1),
(16, '2026_03_30_095645_add_unique_user_date_to_attendances_table', 1),
(17, '2026_03_31_090934_add_late_photo_to_attendances_table', 1),
(18, '2026_05_07_141652_create_overtimes_table', 1),
(19, '2026_05_16_124756_create_company_holidays_table', 1),
(20, '2026_05_22_103148_update_company_holidays_table', 1),
(21, '2026_05_25_155908_add_reject_reason_to_leaves_table', 1),
(22, '2026_06_06_113526_create_positions_table', 1),
(23, '2026_06_06_113615_add_position_id_to_users_table', 1),
(24, '2026_06_17_161707_add_address_to_users_table', 1),
(25, '2026_07_20_201824_add_status_to_overtimes_table', 2);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notifiable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `notifiable_id` bigint UNSIGNED NOT NULL,
  `data` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `type`, `notifiable_type`, `notifiable_id`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
('a22aa332-297e-4641-a3c4-8d4864003cab', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a22aa332-297e-4641-a3c4-8d4864003cab\",\"actions\":[],\"body\":\"Fatimatusyafa Alfafa mengajukan izin\\/sakit (Sakit) dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clipboard-document-list\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Izin Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-03 00:55:03', '2026-07-03 00:55:03'),
('a22aa4af-48d6-4217-a6e1-a168f6bc8012', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a22aa4af-48d6-4217-a6e1-a168f6bc8012\",\"actions\":[],\"body\":\"Rafika Pungki mengajukan izin\\/sakit (Izin) dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clipboard-document-list\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Izin Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-03 00:59:12', '2026-07-03 00:59:12'),
('a22aa598-7ecd-4473-bcea-07decdb7def1', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a22aa598-7ecd-4473-bcea-07decdb7def1\",\"actions\":[],\"body\":\"Daniar Isti Rahmawati mengajukan izin\\/sakit (Sakit) dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clipboard-document-list\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Izin Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-03 01:01:45', '2026-07-03 01:01:45'),
('a232c2b1-abc2-4ded-bdf5-80545205d2af', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a232c2b1-abc2-4ded-bdf5-80545205d2af\",\"actions\":[],\"body\":\"Muamar Maulana Alvarez mengajukan izin\\/sakit (Sakit) dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clipboard-document-list\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Izin Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-07 01:49:44', '2026-07-07 01:49:44'),
('a232c4c0-8185-4ded-8b2f-a738e54fd573', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a232c4c0-8185-4ded-8b2f-a738e54fd573\",\"actions\":[],\"body\":\"Muamar Maulana Alvarez mengajukan izin\\/sakit (Sakit) dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clipboard-document-list\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Izin Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-07 01:55:30', '2026-07-07 01:55:30'),
('a24f6abb-8d67-4d99-8a25-96b36b81b064', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a24f6abb-8d67-4d99-8a25-96b36b81b064\",\"actions\":[],\"body\":\"Reza Maulana mengajukan lembur pada 2026-07-21 dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clock\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Lembur Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-21 07:42:47', '2026-07-21 07:42:47'),
('a2530815-38f8-4ea9-b618-9dd8a7f41da0', 'Filament\\Notifications\\DatabaseNotification', 'App\\Models\\User', 1, '{\"id\":\"a2530815-38f8-4ea9-b618-9dd8a7f41da0\",\"actions\":[],\"body\":\"Muamar Maulana Alvarez mengajukan lembur pada 2026-07-23 dan menunggu persetujuan Anda.\",\"color\":null,\"duration\":\"persistent\",\"icon\":\"heroicon-o-clock\",\"iconColor\":\"warning\",\"status\":\"warning\",\"title\":\"Pengajuan Lembur Baru!\",\"view\":null,\"viewData\":[],\"format\":\"filament\"}', NULL, '2026-07-23 02:50:16', '2026-07-23 02:50:16');

-- --------------------------------------------------------

--
-- Table structure for table `overtimes`
--

CREATE TABLE `overtimes` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `reject_reason` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `overtimes`
--

INSERT INTO `overtimes` (`id`, `user_id`, `date`, `start_time`, `end_time`, `reason`, `status`, `reject_reason`, `created_at`, `updated_at`) VALUES
(1, 4, '2026-07-03', '16:30:00', '17:30:00', 'Menyelesaikan editing video konten IG', 'approved', NULL, '2026-07-03 01:31:29', '2026-07-03 01:31:29'),
(2, 3, '2026-07-03', '16:36:45', '17:32:00', 'Mengerjakan laporan inisiasi proyek awal bulan', 'approved', NULL, '2026-07-03 01:36:45', '2026-07-03 01:36:45'),
(3, 5, '2026-07-02', '16:44:23', '18:28:53', 'Membuat planning job kantor', 'approved', NULL, NULL, NULL),
(4, 6, '2026-07-01', '16:31:20', '17:25:00', 'Mengerjakan rekap keuangan bulanan', 'approved', NULL, NULL, NULL),
(5, 6, '2026-07-07', '16:46:00', '18:00:00', 'Menyelesaikan proyek awal bulan', 'approved', NULL, '2026-07-07 02:02:06', '2026-07-07 02:02:06'),
(6, 6, '2026-07-21', '16:30:00', '18:00:00', 'Menyelesaikan proyek', 'approved', NULL, '2026-07-21 07:42:47', '2026-07-21 07:44:45'),
(7, 4, '2026-07-23', '16:50:00', '18:00:00', 'Menyelesaikan tugas', 'approved', NULL, '2026-07-23 02:50:15', '2026-07-23 02:50:45');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(15, 'App\\Models\\User', 4, 'auth_token', '98d51deb3b746d20cfcb33f8203fba0922329f4719405c2c3ceba1f7f918588c', '[\"*\"]', '2026-07-23 02:52:15', NULL, '2026-07-23 02:45:22', '2026-07-23 02:52:15');

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE `positions` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `positions`
--

INSERT INTO `positions` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'HR Manager', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(2, 'Kepala Divisi Marketing', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(3, 'Kepala Divisi Interior Consultant', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(4, 'Kepala Divisi Finance', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(5, 'Kepala Divisi Warehouse', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(6, 'Kepala Divisi Administrasi', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(7, 'Administrasi', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(8, 'Marketing', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(9, 'Interior Consultant', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(10, 'Finance', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(11, 'Warehouse', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(12, 'Ekspedisi', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(13, 'Produksi', '2026-07-01 06:40:49', '2026-07-01 06:40:49'),
(14, 'Cleaning Service', '2026-07-01 06:40:49', '2026-07-01 06:40:49');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('erJUE7SZJiXe3Kfqin3Uuys8fxViNkW7p6l0cWBr', 1, '10.136.70.141', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', 'YTo4OntzOjY6Il90b2tlbiI7czo0MDoieEFUajV2UHI2Yjc5eDAzRE1QNkE5NWVJTk5Ed3RhSmN4T2pxUzF6WCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHA6Ly8xMC4xMzYuNzAuMTQxOjgwMDAvYWRtaW4vdXNlcnMiO3M6NToicm91dGUiO3M6MzY6ImZpbGFtZW50LmFkbWluLnJlc291cmNlcy51c2Vycy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6MzoidXJsIjthOjA6e31zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToxO3M6MTc6InBhc3N3b3JkX2hhc2hfd2ViIjtzOjY0OiJjOTg0N2UwNjVjZTdmYjRmNmJkY2YyMzlmMDY0MzI0ZmQxNGVhZGE0NDE2NjIxYWNjNDBhNzY1OGJkYjFjZTM4IjtzOjY6InRhYmxlcyI7YTo0OntzOjQwOiJjMTE0NzNlZWJiM2M2Y2EwNWQxMWZkYjdiZGI4ZDQ4Y19jb2x1bW5zIjthOjI6e2k6MDthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo0OiJuYW1lIjtzOjU6ImxhYmVsIjtzOjEzOiJOYW1hIEthcnlhd2FuIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJlbWFpbCI7czo1OiJsYWJlbCI7czoxNDoiRW1haWwgS2FyeWF3YW4iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9fXM6NDA6ImU2NDQ4MzNmNGU0ZTA4NzEyMzE1ZGE3MWIzM2ZhY2QyX2NvbHVtbnMiO2E6Nzp7aTowO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjU6InBob3RvIjtzOjU6ImxhYmVsIjtzOjQ6IkZvdG8iO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjoxO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7YjowO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NDoibmFtZSI7czo1OiJsYWJlbCI7czoxMzoiTmFtYSBLYXJ5YXdhbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MzoibmlwIjtzOjU6ImxhYmVsIjtzOjM6Ik5JSyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjM7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NToiZW1haWwiO3M6NToibGFiZWwiO3M6NToiRW1haWwiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo0O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjEyOiJqYWJhdGFuLm5hbWUiO3M6NToibGFiZWwiO3M6NjoiRGl2aXNpIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJwaG9uZSI7czo1OiJsYWJlbCI7czoxNjoiTm8gSFAgLyBXaGF0c2FwcCI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjY7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTA6ImNyZWF0ZWRfYXQiO3M6NToibGFiZWwiO3M6MTQ6IlRlcmRhZnRhciBQYWRhIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MDtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MTtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO2I6MTt9fXM6NDA6ImRlOTAyYmMwMGM2MDJmM2Y0OWVhZjhlNThmYjEyYzY1X2NvbHVtbnMiO2E6Nzp7aTowO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjk6InVzZXIubmFtZSI7czo1OiJsYWJlbCI7czoxMzoiTmFtYSBLYXJ5YXdhbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjE7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NDoidHlwZSI7czo1OiJsYWJlbCI7czo1OiJKZW5pcyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjI7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6MTA6InN0YXJ0X2RhdGUiO3M6NToibGFiZWwiO3M6MTM6IlRhbmdnYWwgTXVsYWkiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTozO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjg6ImVuZF9kYXRlIjtzOjU6ImxhYmVsIjtzOjE1OiJUYW5nZ2FsIFNlbGVzYWkiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo0O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjY6InJlYXNvbiI7czo1OiJsYWJlbCI7czoxNToiQWxhc2FuIEthcnlhd2FuIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6NTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxMDoiYXR0YWNobWVudCI7czo1OiJsYWJlbCI7czo4OiJMYW1waXJhbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjY7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6Njoic3RhdHVzIjtzOjU6ImxhYmVsIjtzOjY6IlN0YXR1cyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO319czo0MDoiZDFmZTYzODkwNDNjZWNlOTViZDUwMWY1MTg4MWI1NzBfY29sdW1ucyI7YTo3OntpOjA7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6OToidXNlci5uYW1lIjtzOjU6ImxhYmVsIjtzOjEzOiJOYW1hIEthcnlhd2FuIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MTthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czoxMzoidXNlci5wb3NpdGlvbiI7czo1OiJsYWJlbCI7czo2OiJEaXZpc2kiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aToyO2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjQ6ImRhdGUiO3M6NToibGFiZWwiO3M6MTQ6IlRhbmdnYWwgTGVtYnVyIjtzOjg6ImlzSGlkZGVuIjtiOjA7czo5OiJpc1RvZ2dsZWQiO2I6MTtzOjEyOiJpc1RvZ2dsZWFibGUiO2I6MDtzOjI0OiJpc1RvZ2dsZWRIaWRkZW5CeURlZmF1bHQiO047fWk6MzthOjc6e3M6NDoidHlwZSI7czo2OiJjb2x1bW4iO3M6NDoibmFtZSI7czo1OiJ3YWt0dSI7czo1OiJsYWJlbCI7czoxMDoiSmFtIExlbWJ1ciI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjQ7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6NjoiZHVyYXNpIjtzOjU6ImxhYmVsIjtzOjEyOiJUb3RhbCBEdXJhc2kiO3M6ODoiaXNIaWRkZW4iO2I6MDtzOjk6ImlzVG9nZ2xlZCI7YjoxO3M6MTI6ImlzVG9nZ2xlYWJsZSI7YjowO3M6MjQ6ImlzVG9nZ2xlZEhpZGRlbkJ5RGVmYXVsdCI7Tjt9aTo1O2E6Nzp7czo0OiJ0eXBlIjtzOjY6ImNvbHVtbiI7czo0OiJuYW1lIjtzOjY6InJlYXNvbiI7czo1OiJsYWJlbCI7czoyMjoiUGVrZXJqYWFuIC8gS2V0ZXJhbmdhbiI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO31pOjY7YTo3OntzOjQ6InR5cGUiO3M6NjoiY29sdW1uIjtzOjQ6Im5hbWUiO3M6Njoic3RhdHVzIjtzOjU6ImxhYmVsIjtzOjY6IlN0YXR1cyI7czo4OiJpc0hpZGRlbiI7YjowO3M6OToiaXNUb2dnbGVkIjtiOjE7czoxMjoiaXNUb2dnbGVhYmxlIjtiOjA7czoyNDoiaXNUb2dnbGVkSGlkZGVuQnlEZWZhdWx0IjtOO319fXM6ODoiZmlsYW1lbnQiO2E6MDp7fX0=', 1784776400);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` bigint UNSIGNED NOT NULL,
  `office_latitude` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `office_longitude` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `radius` int NOT NULL,
  `start_time` time NOT NULL DEFAULT '06:00:00',
  `time_in_limit` time NOT NULL,
  `time_out_limit` time NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `office_latitude`, `office_longitude`, `radius`, `start_time`, `time_in_limit`, `time_out_limit`, `created_at`, `updated_at`) VALUES
(1, '-7.8023009967889', '111.97982069192', 100, '06:00:00', '07:30:00', '16:30:00', '2026-07-01 06:40:59', '2026-07-21 06:09:30');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `nip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','pegawai') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pegawai',
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fcm_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `position_id` bigint UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nip`, `name`, `email`, `address`, `email_verified_at`, `password`, `device_id`, `photo`, `role`, `phone`, `position`, `fcm_token`, `remember_token`, `created_at`, `updated_at`, `position_id`) VALUES
(1, '00001', 'Admin Candratama', 'admin@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$TG0zTuJln6/oNo4K4kMobOuOYIVGrzsuyXP9do6mMwfHrS5Uytiy6', '', 'profile-photos/01KWJW8EZ3SYJFSDWD302TCCFP.jpg', 'admin', '081234567890', 'Manager', NULL, NULL, '2026-07-01 06:40:56', '2026-07-03 02:17:25', NULL),
(2, '00002', 'Amirada Nur Laily', 'amirada@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$idlb/6f70Z.t4faeUwBDI.aoZqoINDB6a2yKcD63eKbghl4l36Fry', NULL, NULL, 'pegawai', '081234567890', 'Kepala Divisi Marketing', NULL, NULL, '2026-07-01 06:40:57', '2026-07-03 01:55:28', 2),
(3, '00003', 'Fatimatusyafa Alfafa', 'alfafa@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$8pbhKIv7xUI8nFr4LdZhxeeyOVvuGHoBBDomuofDgVaD1t7zd/xE2', 'Redmi-24117RN76O-BP2A.250605.031.A3', NULL, 'pegawai', '081234567890', 'Marketing', NULL, NULL, '2026-07-01 06:40:57', '2026-07-03 01:55:49', 8),
(4, '00004', 'Muamar Maulana Alvarez', 'alvarez@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$B5wsFOC6ihqTb9yZU3hijuT1pV/WCfxVlwcpr.W.EEXSlAnTqZ/nm', 'Redmi-24117RN76O-BP2A.250605.031.A3', NULL, 'pegawai', '081234567890', 'Marketing', 'fErJ5n9LTEGNsaLad1Pvt4:APA91bGRz2BWLABI-GwQ8Z7hzQhGh0hdCnrLSXfIP-hGaY3K4EsYSA1Fz3dQkUPOJjkw9FYCXdtftip-jPS9AtBXHIvyQ3bCvGAR6G_WvFgb9l1FncOYX_M', NULL, '2026-07-01 06:40:57', '2026-07-23 02:45:28', 8),
(5, '00005', 'Daniar Isti Rahmawati', 'daniar@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$4t3kLh1R/V.Ye.fJs3cChuDGVLHp33pt0BnC6NnAy/OhI/CMcuKcG', 'Redmi-24117RN76O-BP2A.250605.031.A3', NULL, 'pegawai', '081234567890', 'Marketing', NULL, NULL, '2026-07-01 06:40:57', '2026-07-03 01:57:38', 8),
(6, '0006', 'Reza Maulana', 'reza@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$uR6S/a4krMwHnNOtgBonaOqC81SxugYwedSSM5pTQjkqwjMGwGqLu', 'Redmi-24117RN76O-BP2A.250605.031.A3', 'profiles/jMOhvkyutaBxOm2hNvpEdNjARk9RAkKjfzpfT6qA.jpg', 'pegawai', '081234567890', 'Marketing', NULL, NULL, '2026-07-01 06:40:57', '2026-07-23 02:45:09', 8),
(7, '0007', 'Tabea Al-Haq', 'tabea@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$ICXsAZup4HS/qma/GTvE2OvBYITbyAIB32Qrqy2BXvkHu7fLiKl/G', NULL, NULL, 'pegawai', '081234567890', 'Finance', NULL, NULL, '2026-07-01 06:40:58', '2026-07-03 01:58:45', 10),
(8, '0008', 'Putri Nur Aisyah', 'putri@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$5q97VUPOQG5APVTID2Uv1u02k/dvZ8D.rGPWOVCtdBl2iFTQzJ9UG', NULL, NULL, 'pegawai', '081234567890', 'Finance', NULL, NULL, '2026-07-01 06:40:58', '2026-07-03 01:59:10', 10),
(9, '0009', 'Rizki Kurniawan', 'rizki@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$Zn/F1Eo8nIhx07P7QVRhyOwQMqf5I2.FtEYnwaWsgZWwEIIBKb292', NULL, NULL, 'pegawai', '081234567890', 'Finance', NULL, NULL, '2026-07-01 06:40:58', '2026-07-03 01:59:44', 11),
(10, '0010', 'Ahmad Khoirudin', 'ahmad@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$4SGsiLLXxitDr0PjwcKciuRWx4g5RhDmy5GbTIYBtvAX/khK3DcC2', NULL, NULL, 'pegawai', '081234567890', 'Warehouse', NULL, NULL, '2026-07-01 06:40:58', '2026-07-03 02:00:11', 13),
(11, '0011', 'Achmad Fauzi', 'achmad@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$A61TALd0cKNXWMDHB.WyIuzSFvdju/K5OOSuUerxJIL44gAh95/Ke', NULL, NULL, 'pegawai', '081234567890', 'Cleaning Service', NULL, NULL, '2026-07-01 06:40:58', '2026-07-03 02:00:51', 14),
(12, '0012', 'Rafika Pungki', 'rafika@gmail.com', 'Kota Kediri, Jawa Timur', NULL, '$2y$12$P1Hmc4tdJyKueDwLC8Y.kekP1gGGKk7CNi0gyhsKWLaRDDopuo7rm', 'Redmi-24117RN76O-BP2A.250605.031.A3', NULL, 'pegawai', '081234567890', 'Finance', NULL, NULL, '2026-07-01 06:40:59', '2026-07-03 02:01:20', 9),
(14, '12345', 'Aldi Dwi', 'aldi@gmail.com', 'Bandar lor', NULL, '$2y$12$Kilpix.kuj5ZaAFXdURRxe7i1asqqe54bcZOghd1VCsbxfBIYOhw6', 'Redmi-24117RN76O-BP2A.250605.031.A3', 'profiles/aNfB71NoFwCaicy6QEAFdtQr2hTLgGn2y0x7Eirg.jpg', 'pegawai', '08233157692', NULL, NULL, NULL, '2026-07-03 01:52:50', '2026-07-03 02:21:42', 7),
(17, '11990', 'Aldi Irawan', 'aldidwi@gmail.com', 'Kediri', NULL, '$2y$12$8mK0AzsqzTetRa7sFo1/RevqeTAyd5yur0pAszZMQmdrO3UqRpapG', NULL, NULL, 'pegawai', '082316741298', NULL, NULL, NULL, '2026-07-07 02:09:44', '2026-07-07 02:09:44', 7);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `app_notifications`
--
ALTER TABLE `app_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `app_notifications_user_id_foreign` (`user_id`);

--
-- Indexes for table `attendances`
--
ALTER TABLE `attendances`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_date_unique` (`user_id`,`date`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `company_holidays`
--
ALTER TABLE `company_holidays`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_holidays_date_unique` (`start_date`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `leaves`
--
ALTER TABLE `leaves`
  ADD PRIMARY KEY (`id`),
  ADD KEY `leaves_user_id_foreign` (`user_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`);

--
-- Indexes for table `overtimes`
--
ALTER TABLE `overtimes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `overtimes_user_id_foreign` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_nip_unique` (`nip`),
  ADD KEY `users_position_id_foreign` (`position_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `app_notifications`
--
ALTER TABLE `app_notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT for table `attendances`
--
ALTER TABLE `attendances`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `company_holidays`
--
ALTER TABLE `company_holidays`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leaves`
--
ALTER TABLE `leaves`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `overtimes`
--
ALTER TABLE `overtimes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `positions`
--
ALTER TABLE `positions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `app_notifications`
--
ALTER TABLE `app_notifications`
  ADD CONSTRAINT `app_notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `attendances`
--
ALTER TABLE `attendances`
  ADD CONSTRAINT `attendances_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `leaves`
--
ALTER TABLE `leaves`
  ADD CONSTRAINT `leaves_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `overtimes`
--
ALTER TABLE `overtimes`
  ADD CONSTRAINT `overtimes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_position_id_foreign` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
