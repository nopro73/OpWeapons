package com.nopro73.opweapons;

import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.ShapedRecipe;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.ChatColor;

public class OpWeapons extends JavaPlugin {

    @Override
    public void onEnable() {
        getLogger().info("OpWeapons has been successfully enabled!");
        registerHeartWeaponRecipe();
    }

    @Override
    public void onDisable() {
        getLogger().info("OpWeapons has been disabled.");
    }

    private void registerHeartWeaponRecipe() {
        ItemStack heartWeapon = new ItemStack(Material.DIAMOND_SWORD);
        ItemMeta meta = heartWeapon.getItemMeta();
        if (meta != null) {
            meta.setDisplayName(ChatColor.RED + "" + ChatColor.BOLD + "Heart Weapon");
            heartWeapon.setItemMeta(meta);
        }

        ShapedRecipe recipe = new ShapedRecipe(heartWeapon);
        recipe.shape(" B ", " N ", " S ");
        
        recipe.setIngredient('B', Material.BOW);
        recipe.setIngredient('N', Material.NETHER_STAR);
        recipe.setIngredient('S', Material.DIAMOND_SWORD);

        Bukkit.addRecipe(recipe);
    }
}
