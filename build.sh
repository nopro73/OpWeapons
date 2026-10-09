#!/bin/bash
echo "=== CRITICAL REBUILD SYSTEM STARTED ==="
rm -rf src target pom.xml plugin.yml

# 1. Force write perfect POM file
cat << 'EOF' > pom.xml
<project xmlns="http://apache.org" xmlns:xsi="http://w3.org"
  xsi:schemaLocation="http://apache.org http://apache.org">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>HeartWeapons</artifactId>
  <version>1.0</version>
  <properties>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
  <repositories>
    <repository>
      <id>codemc-repo</id>
      <url>https://codemc.org</url>
    </repository>
  </repositories>
  <dependencies>
    <dependency>
      <groupId>org.spigotmc</groupId>
      <artifactId>spigot-api</artifactId>
      <version>1.12.2-R0.1-SNAPSHOT</version>
      <scope>provided</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>3.2.0</version>
      </plugin>
    </plugins>
  </build>
</project>
EOF

# 2. Force create fresh directory trees
mkdir -p src/main/java/com/example/heartweapons
mkdir -p src/main/resources

# 3. Force write plugin.yml metadata
cat << 'EOF' > src/main/resources/plugin.yml
name: HeartWeapons
version: 1.0
main: com.example.heartweapons.HeartWeapons
api-version: 1.12
author: Developer
description: Adds custom weapons crafted with LifeSteal hearts.
EOF

# 4. Force write perfect clean Java logic
cat << 'EOF' > src/main/java/com/example/heartweapons/HeartWeapons.java
package com.example.heartweapons;

import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.entity.Arrow;
import org.bukkit.entity.LivingEntity;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
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

    @SuppressWarnings("deprecation")
    private void registerRecipes() {
        ItemStack heartItem = new ItemStack(Material.NETHER_STAR); 
        ItemMeta heartMeta = heartItem.getItemMeta();
        if (heartMeta != null) {
            heartMeta.setDisplayName("§cHeart");
            heartItem.setItemMeta(heartMeta);
        }
        ItemStack customBow = new ItemStack(Material.BOW);
        ItemMeta bowMeta = customBow.getItemMeta();
        if (bowMeta != null) {
            bowMeta.setDisplayName("§eHeart Piercer Bow");
            bowMeta.setLore(Arrays.asList("§7Applies a random negative effect", "§7to targets for 10 seconds."));
            customBow.setItemMeta(bowMeta);
        }
        ShapedRecipe bowRecipe = new ShapedRecipe(customBow);
        bowRecipe.shape("HHH", "HBH", "HHH");
        bowRecipe.setIngredient('H', Material.NETHER_STAR);
        bowRecipe.setIngredient('B', Material.BOW);
        Bukkit.addRecipe(bowRecipe);

        ItemStack customSword = new ItemStack(Material.DIAMOND_SWORD);
        ItemMeta swordMeta = customSword.getItemMeta();
        if (swordMeta != null) {
            swordMeta.setDisplayName("§4Heart Infused Blade");
            swordMeta.setLore(Arrays.asList("§7Deals massive true damage", "§7and inflicts Poison II."));
            customSword.setItemMeta(swordMeta);
        }
        ShapedRecipe swordRecipe = new ShapedRecipe(customSword);
        swordRecipe.shape("HHH", "HSH", "HHH");
        swordRecipe.setIngredient('H', Material.NETHER_STAR);
        swordRecipe.setIngredient('S', Material.DIAMOND_SWORD);
        Bukkit.addRecipe(swordRecipe);
    }

    @SuppressWarnings("deprecation")
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
                    target.addPotionEffect(new PotionEffect(randomEffect, 200, 0));
                }
            }
        }
    }

    @SuppressWarnings("deprecation")
    @EventHandler
    public void onSwordHit(EntityDamageByEntityEvent event) {
        if (event.getDamager() instanceof Player && event.getEntity() instanceof LivingEntity) {
            Player attacker = (Player) event.getDamager();
            ItemStack sword = attacker.getInventory().getItemInMainHand();
            if (sword != null && sword.getType() == Material.DIAMOND_SWORD && sword.hasItemMeta() && 
                sword.getItemMeta().getDisplayName().equals("§4Heart Infused Blade")) {
                LivingEntity target = (LivingEntity) event.getEntity();
                event.setDamage(10.0);
                target.addPotionEffect(new PotionEffect(PotionEffectType.POISON, 100, 1));
            }
        }
    }
}
EOF

# 5. Compile cleanly
mvn -B clean package --file pom.xml
