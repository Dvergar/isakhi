import 'dart:collection';

class EntitySet {
  EntityManager em;
  Set<Type> code;
  Set<Entity> _adds = Set();
  Set<Entity> _changes = Set();
  Set<Entity> _removes = Set();
  Set<Entity> adds = Set();
  Set<Entity> changes = Set();
  Set<Entity> removes = Set();

  EntitySet(this.em, this.code);

  applyChanges() {
    adds = _adds;
    changes = _changes;
    removes = _removes;

    _adds = Set();
    _changes = Set();
    _removes = Set();
  }
}

class Entity {
  int id;
  Set<Type> code = Set();

  HashMap<Type, Component> components = HashMap();

  Entity(this.id);
}

class EntityManager {
  int ids = 0;

  List<EntitySet> entitySets = List();
  List<Entity> entities = List();
  List<Entity> destroyedEntities = List();

  createEntity() {
    var entityId = ids++;
    var entity = Entity(entityId);
    entities.add(entity);
    return entity;
  }

  destroyEntity(Entity entity) {
    for (var entitySet in entitySets) {
      for (var componentType in entity.components.keys) {
        if (entitySet.code.contains(componentType)) {
          entitySet._removes.add(entity);
          break;
        }
      }
    }

    destroyedEntities.add(entity);
  }

  addComponent(Entity entity, Component instance) {
    entity.components[instance.runtimeType] = instance;

    for (var entitySet in entitySets) {
      if (entitySet.code.containsAll(entity.code)) {
        entitySet._adds.add(entity);
      }
    }
  }

  Component getComponent(Entity entity, Type componentClass) {
    if (!entity.components.containsKey(componentClass))
      throw new Exception("No component attached to this entity");

    return entity.components[componentClass];
  }

  removeComponent(Entity entity, Type componentClass) {
    for (var entitySet in entitySets) {
      if (entitySet.code.contains(componentClass)) {
        entitySet._removes.add(entity);
      }
    }
  }

  EntitySet getEntitySet(List<Type> code) {
    var entitySet = EntitySet(this, code.toSet());

    for (var entity in entities) {
      if (entitySet.code.containsAll(entity.code)) {
        entitySet._adds.add(entity);
      }
    }
    entitySets.add(entitySet);
    return entitySet;
  }

  markChanged(Entity entity, Component component, [EntitySet filterEntitySet]) {
    for (var entitySet in entitySets) {
      if (entitySet == filterEntitySet) continue;
      if (entitySet.code.contains(component.runtimeType)) {
        entitySet._changes.add(entity);
      }
    }
  }

  destroyMarkedEntities() {
    for (var entity in destroyedEntities) {
      entities.remove(entity);
    }
  }
}

abstract class Component {}
