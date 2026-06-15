CREATE DATABASE IF NOT EXISTS klinik_db;
USE klinik_db;

CREATE TABLE IF NOT EXISTS pasien (
    id VARCHAR(50) PRIMARY KEY,
    nomor_rm VARCHAR(50) UNIQUE NOT NULL,
    nama_pasien VARCHAR(100) NOT NULL,
    tgllhr_pasien DATE NOT NULL,
    telp_pasien VARCHAR(20) NOT NULL,
    alamat_pasien TEXT NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pegawai (
    id VARCHAR(50) PRIMARY KEY,
    nip_pegawai VARCHAR(50) UNIQUE NOT NULL,
    nama_pegawai VARCHAR(100) NOT NULL,
    tgllhr_pegawai DATE NOT NULL,
    telp_pegawai VARCHAR(20) NOT NULL,
    email_pegawai VARCHAR(100) UNIQUE NOT NULL,
    password_pegawai VARCHAR(255) NOT NULL,
    jabatan_pegawai VARCHAR(50) DEFAULT 'Pegawai',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS poli (
    id VARCHAR(50) PRIMARY KEY,
    nama_poli VARCHAR(100) NOT NULL,
    kode_poli VARCHAR(50) NOT NULL,
    deskripsi_poli TEXT,
    kuota_harian INT DEFAULT 30,
    status_aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS jadwal_poli (
    id VARCHAR(50) PRIMARY KEY,
    id_poli VARCHAR(50) NOT NULL,
    id_pegawai VARCHAR(50) NOT NULL,
    hari VARCHAR(20) NOT NULL,
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    kuota INT NOT NULL DEFAULT 0,
    status_aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_poli) REFERENCES poli(id) ON DELETE CASCADE,
    FOREIGN KEY (id_pegawai) REFERENCES pegawai(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS antrian (
    id VARCHAR(50) PRIMARY KEY,
    poli_id VARCHAR(50) NOT NULL,
    jadwal_id VARCHAR(50) NULL,
    pasien_id VARCHAR(50) NOT NULL,
    tanggal DATE NOT NULL,
    nomor_antrian VARCHAR(20) NOT NULL,
    status VARCHAR(50) DEFAULT 'Menunggu',
    waktu_daftar DATETIME NOT NULL,
    waktu_panggil DATETIME NULL,
    waktu_selesai DATETIME NULL,
    prioritas BOOLEAN DEFAULT FALSE,
    keluhan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (poli_id) REFERENCES poli(id) ON DELETE CASCADE,
    FOREIGN KEY (pasien_id) REFERENCES pasien(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS counters (
    id VARCHAR(50) PRIMARY KEY,
    poli_id VARCHAR(50) NOT NULL,
    tanggal DATE NOT NULL,
    current INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (poli_id, tanggal)
);

-- Insert dummy Admin if not exists
INSERT IGNORE INTO pegawai (id, nip_pegawai, nama_pegawai, tgllhr_pegawai, telp_pegawai, email_pegawai, password_pegawai, jabatan_pegawai)
VALUES ('admin_id', '000', 'Administrator', '1990-01-01', '000', 'admin', 'admin', 'Admin');

CREATE TABLE IF NOT EXISTS obat (
    id VARCHAR(50) PRIMARY KEY,
    nama_obat VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    harga DECIMAL(10, 2) NOT NULL DEFAULT 0,
    stok INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rekam_medis (
    id VARCHAR(50) PRIMARY KEY,
    antrian_id VARCHAR(50) NOT NULL,
    pasien_id VARCHAR(50) NOT NULL,
    pegawai_id VARCHAR(50) NOT NULL,
    diagnosa TEXT NOT NULL,
    biaya_jasa DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total_biaya_obat DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status_pembayaran VARCHAR(20) DEFAULT 'Belum Lunas',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (antrian_id) REFERENCES antrian(id) ON DELETE CASCADE,
    FOREIGN KEY (pasien_id) REFERENCES pasien(id) ON DELETE CASCADE,
    FOREIGN KEY (pegawai_id) REFERENCES pegawai(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS resep_obat (
    id VARCHAR(50) PRIMARY KEY,
    rekam_medis_id VARCHAR(50) NOT NULL,
    obat_id VARCHAR(50) NOT NULL,
    jumlah INT NOT NULL DEFAULT 1,
    harga_satuan DECIMAL(10, 2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (rekam_medis_id) REFERENCES rekam_medis(id) ON DELETE CASCADE,
    FOREIGN KEY (obat_id) REFERENCES obat(id) ON DELETE CASCADE
);
