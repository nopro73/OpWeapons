package com.example.heartweapons;

import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.NamespacedKey;
import org.bukkit.entity.Arrow;
import org.bukkit.entity.LivingEntity;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.ProjectileHitEvent;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.ShapedRecipe;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.potion.PotionEffect;
import org.bukkit.potion.PotionEffectType;

import java.util.Arrays;
import java.util.Random;

public class HeartWeapons extends JavaPlugin implements Listener {

    private final Random random = new Random();
    private final PotionEffectType[] negativeEffects = {
        PotionEffectType.SLOW, PotionEffectType.WEAKNESS, 
        PotionEffectType.POISON, PotionEffectType.BLINDNESS, 
        PotionEffectType.WITHER
    };

    @Override
    public void onEnable() {
        Bukkit.getPluginManager().registerEvents(this, this);
        registerRecipes();
    }

    private void registerRecipes() {
        // Define GreatLifeSteal heart blueprint item matching your server setup
        // Note: Change Material.NETHER_STAR to your exact config heart item if different
        ItemStack heartItem = new ItemStack(Material.NETHER_STAR); 
        ItemMeta heartMeta = heartItem.getItemMeta();
        if (heartMeta != null) {
            heartMeta.setDisplayName("§cHeart"); // Matches GreatLifeSteal default string colors
            heartItem.setItemMeta(heartMeta);
        }

        // Custom Bow Creation
        ItemStack customBow = new ItemStack(Material.BOW);
        ItemMeta bowMeta = customBow.getItemMeta();
        if (bowMeta != null) {
            bowMeta.setDisplayName("§eHeart Piercer Bow");
            bowMeta.setLore(Arrays.asList("§7Applies a random negative effect", "§7to targets for 10 seconds."));
            customBow.setItemMeta(bowMeta);
        }

        NamespacedKey bowKey = new NamespacedKey(this, "heart_bow");
        ShapedRecipe bowRecipe = new ShapedRecipe(bowKey, customBow);
        bowRecipe.shape("HHH", "HBH", "HHH");
        bowRecipe.setIngredient('H', heartItem.getData());
        bowRecipe.setIngredient('B', Material.BOW);
        Bukkit.addRecipe(bowRecipe);

        // Custom Sword Creation
        ItemStack customSword = new ItemStack(Material.DIAMOND_SWORD);
        ItemMeta swordMeta = customSword.getItemMeta();
        if (swordMeta != null) {
            swordMeta.setDisplayName("§4Heart Infused Blade");
            swordMeta.setLore(Arrays.asList("§7Deals massive true damage", "§7and inflicts Poison II."));
            customSword.setItemMeta(swordMeta);
        }

        NamespacedKey swordKey = new NamespacedKey(this, "heart_sword");
        ShapedRecipe swordRecipe = new ShapedRecipe(swordKey, customSword);
        swordRecipe.shape("HHH", "HSH", "HHH");
        swordRecipe.setIngredient('H', heartItem.getData());
        swordRecipe.setIngredient('S', Material.DIAMOND_SWORD);
        Bukkit.addRecipe(swordRecipe);
    }

    @EventHandler
    public void onBowHit(EntityDamageByEntityEvent event) {
        if (event.getDamager() instanceof Arrow) {
            Arrow arrow = (Arrow) event.getDamager();
            if (arrow.getShooter() instanceof Player && event.getEntity() instanceof LivingEntity) {
                Player shooter = (Player) arrow.getShooter();
                ItemStack bow = shooter.getInventory().getItemInMainHand();
                
                if (bow != null && bow.getType() == Material.BOW && bow.hasItemMeta() && 
                    bow.getItemMeta().getDisplayName().equals("§eHeart Piercer Bow")) {
                    
                    LivingEntity target = (LivingEntity) event.getEntity();
                    PotionEffectType randomEffect = negativeEffects[random.nextInt(negativeEffects.length)];
                    target.addPotionEffect(new PotionEffect(randomEffect, 200, 0)); // 200 ticks = 10s
                }
            }
        }
    }

    @EventHandler
    public void onSwordHit(EntityDamageByEntityEvent event) {
        if (event.getDamager() instanceof Player && event.getEntity() instanceof LivingEntity) {
            Player attacker = (Player) event.getDamager();
            ItemStack sword = attacker.getInventory().getItemInMainHand();

            if (sword != null && sword.getType() == Material.DIAMOND_SWORD && sword.hasItemMeta() && 
                sword.getItemMeta().getDisplayName().equals("§4Heart Infused Blade")) {
                
                LivingEntity target = (LivingEntity) event.getEntity();
                
                // Override to deal 10 flat base damage (5 Hearts)
                event.setDamage(10.0);
                
                // Add Poison II (Amplifier 1) for 5 seconds (100 ticks)
                target.addPotionEffect(new PotionEffect(PotionEffectType.POISON, 100, 1));
            }
        }
    }
}
